import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:pegue_o_doce/categoria/models/categoria.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/empresa/services/empresa_service.dart';
import 'package:pegue_o_doce/empresa/views/visualizacao_empresa.dart';
import 'package:pegue_o_doce/utils/tema.dart';

class PesquisaEmpresaPage extends ConsumerStatefulWidget {
  final Categoria categoria;
  const PesquisaEmpresaPage({super.key, required this.categoria});

  @override
  ConsumerState<PesquisaEmpresaPage> createState() {
    return PesquisaEmpresaPageState();
  }
}

class PesquisaEmpresaPageState extends ConsumerState<PesquisaEmpresaPage> {
  Categoria get categoria => widget.categoria;
  final TextEditingController _pesquisaController = TextEditingController();
  bool ordenarAsc = true;

  @override
  void initState() {
    super.initState();
    _pesquisaController.addListener(listenerPesquisa);
  }

  @override
  void dispose() {
    _pesquisaController.removeListener(listenerPesquisa);
    _pesquisaController.dispose();
    super.dispose();
  }

  void listenerPesquisa() => setState(() {});

  Future<List<Empresa>> obterEmpresas() async {
    Future<Set<Empresa>> empresas = ref
        .watch(empresaServiceProvider)
        .obterListaEmpresasPorCategoriaDoProduto(categoria.id!);
    final empresasList = await empresas.then((value) => value.toList());
    return removerEmpresasDuplicadas(empresasList);
  }

  List<Empresa> removerEmpresasDuplicadas(List<Empresa> empresas) {
    final empresasUnicas = <Empresa>[];
    final idsEmpresas = <String>{};
    for (final empresa in empresas) {
      if (empresa.id != null && !idsEmpresas.contains(empresa.id)) {
        idsEmpresas.add(empresa.id!);
        empresasUnicas.add(empresa);
      }
    }
    return empresasUnicas;
  }

  List<Empresa> filtrarEOrdenar(List<Empresa> listaEmpresas) {
    final term = _pesquisaController.text.trim().toLowerCase();
    if (term.isNotEmpty) {
      final fuse =
          Fuzzy<String>(listaEmpresas.map((e) => e.nomeFantasia).toList());
      final results = fuse.search(term);
      listaEmpresas = results.map((r) {
        return listaEmpresas.firstWhere((e) => e.nomeFantasia == r.item);
      }).toList();
    }
    listaEmpresas.sort((a, b) => ordenarAsc
        ? a.nomeFantasia.compareTo(b.nomeFantasia)
        : b.nomeFantasia.compareTo(a.nomeFantasia));
    return listaEmpresas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.padrao('Pesquisa de Empresas'),
      body: Column(
        children: [
          retornarCabecalho(),
          retornarBarraPesquisa(),
          FutureBuilder<List<Empresa>>(
            future: obterEmpresas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Expanded(
                    child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Expanded(
                  child: Center(
                    child: Text('Erro: ${snapshot.error}'),
                  ),
                );
              }
              final listaEmpresas = snapshot.data!;
              final listaEmpresasFiltradas = filtrarEOrdenar(listaEmpresas);
              return Expanded(
                child: listaEmpresasFiltradas.isEmpty
                    ? Center(
                        child: Text(
                          _pesquisaController.text.isEmpty
                              ? 'Nenhuma empresa disponível.'
                              : 'Nenhum resultado para "${_pesquisaController.text}"',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Column(
                        children: [
                          retornarContagemItens(listaEmpresasFiltradas.length),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 12),
                              physics: const BouncingScrollPhysics(),
                              itemCount: listaEmpresasFiltradas.length,
                              itemBuilder: (_, i) => retornarCardEmpresa(
                                  listaEmpresasFiltradas[i]),
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget retornarCabecalho() => Container(
        width: double.infinity,
        color: Colors.grey[300],
        padding: const EdgeInsets.all(8),
        child: Text(
          'CATEGORIA: ${categoria.nome}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );

  Widget retornarBarraPesquisa() => Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _pesquisaController,
                decoration: InputDecoration(
                  labelText: 'Pesquisar por nome',
                  prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(ordenarAsc
                  ? FontAwesomeIcons.arrowDownAZ
                  : FontAwesomeIcons.arrowUpAZ),
              tooltip: 'Ordenar A-Z/Z-A',
              onPressed: () => setState(() => ordenarAsc = !ordenarAsc),
            ),
          ],
        ),
      );

  Widget retornarContagemItens(int count) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '$count resultado(s)',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      );

  Widget retornarCardEmpresa(Empresa e) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VisualizacaoEmpresaPage(empresa: e),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.buildingFlag, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.nomeFantasia,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (e.locaisEntrega.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          e.locaisEntrega
                              .asMap()
                              .entries
                              .map((e) => e.value.nome)
                              .toList()
                              .join(', '),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
}
