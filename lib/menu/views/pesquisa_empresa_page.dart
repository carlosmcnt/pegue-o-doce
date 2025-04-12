import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  @override
  void initState() {
    super.initState();
  }

  Future<List<Empresa>> obterEmpresasPorCategoria(String categoriaId) {
    Future<Set<Empresa>> empresas = ref
        .watch(empresaServiceProvider)
        .obterListaEmpresasPorCategoriaDoProduto(categoriaId);
    return empresas.then((value) => value.toList());
  }

  List<Empresa> removerEmpresasDuplicadas(List<Empresa> empresas) {
    final empresasUnicas = <Empresa>[];
    final idsEmpresas = <String>{};
    for (final empresa in empresas) {
      if (!idsEmpresas.contains(empresa.id)) {
        idsEmpresas.add(empresa.id!);
        empresasUnicas.add(empresa);
      }
    }
    return empresasUnicas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.descricaoAcoes(
        'Pesquisa de Empresas',
        [],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[300],
            child: Text(
              'CATEGORIA: ${categoria.nome}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Flexible(
            child: carregarListaEmpresas(),
          ),
        ],
      ),
    );
  }

  FutureBuilder<List<Empresa>> carregarListaEmpresas() {
    return FutureBuilder<List<Empresa>>(
      future: obterEmpresasPorCategoria(categoria.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar empresas: ${snapshot.error}'),
          );
        } else {
          final empresas = removerEmpresasDuplicadas(snapshot.data!);
          if (empresas.isEmpty) {
            return const Center(
              child: Text(
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  'Nenhuma empresa que vende essa categoria de produto foi encontrada'),
            );
          } else {
            return listarEmpresas(empresas);
          }
        }
      },
    );
  }

  ListView listarEmpresas(List<Empresa> empresas) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(10),
      itemCount: empresas.length,
      itemBuilder: (context, index) {
        final empresa = empresas[index];
        return ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VisualizacaoEmpresaPage(
                  empresa: empresa,
                ),
              ),
            );
          },
          leading: const Icon(FontAwesomeIcons.buildingFlag),
          tileColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(empresa.nomeFantasia),
          subtitle: empresa.locaisEntrega.isEmpty
              ? const Text('Sem locais de entrega')
              : RichText(
                  text: TextSpan(
                    children: [
                      const WidgetSpan(child: Icon(Icons.location_on)),
                      TextSpan(
                        text: empresa.locaisEntrega.join(', '),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
