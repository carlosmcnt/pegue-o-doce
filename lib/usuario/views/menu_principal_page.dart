import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:pegue_o_doce/categoria/models/categoria.dart';
import 'package:pegue_o_doce/categoria/repositories/categoria_repository.dart';
import 'package:pegue_o_doce/menu/views/menu_lateral.dart';
import 'package:pegue_o_doce/menu/views/pesquisa_empresa_page.dart';
import 'package:pegue_o_doce/utils/tema.dart';

class MenuPrincipalPage extends ConsumerStatefulWidget {
  const MenuPrincipalPage({super.key});

  @override
  ConsumerState<MenuPrincipalPage> createState() => MenuPrincipalWidgetState();
}

class MenuPrincipalWidgetState extends ConsumerState<MenuPrincipalPage> {
  late Future<List<Categoria>> listaCategoriasFuture;
  List<Categoria> totalCategorias = [];
  List<Categoria> categoriasEmExibicao = [];
  String textoPesquisa = '';

  @override
  void initState() {
    super.initState();
    listaCategoriasFuture = carregarCategorias();
  }

  Future<List<Categoria>> carregarCategorias() async {
    final categorias =
        await ref.read(categoriaRepositoryProvider).getCategoriasAtivas();
    totalCategorias = categorias;
    categoriasEmExibicao = categorias.take(6).toList();
    return categorias;
  }

  void atualizarFiltro(String texto) {
    textoPesquisa = texto;
    if (textoPesquisa.isEmpty) {
      setState(() {
        categoriasEmExibicao = totalCategorias.take(6).toList();
      });
    } else {
      final fuse = Fuzzy<String>(
        totalCategorias.map((c) => c.nome).toList(),
        options: FuzzyOptions(
          findAllMatches: false,
          threshold: 0.2,
          distance: 20,
          minMatchCharLength: 2,
        ),
      );
      final resultados = fuse.search(textoPesquisa);
      final encontrados = resultados.map((r) {
        return totalCategorias.firstWhere((c) => c.nome == r.item);
      }).toList();
      setState(() {
        categoriasEmExibicao = encontrados;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.menuPrincipal(),
      drawer: const MenuLateralWidget(),
      body: FutureBuilder<List<Categoria>>(
        future: listaCategoriasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar categorias.'));
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  retornarCabecalho(),
                  const SizedBox(height: 12),
                  retornarBarraPesquisa(),
                  retornarContagemItens(),
                  const SizedBox(height: 12),
                  retornarGridCategorias(categoriasEmExibicao),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget retornarCabecalho() {
    return const Column(
      children: [
        Text(
          'Bem-vindo ao Pegue o Doce!\nEscolha uma categoria',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Filtre e selecione uma categoria para visualizar mais detalhes.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget retornarBarraPesquisa() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar por categoria',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: atualizarFiltro,
            ),
          ),
          const SizedBox(width: 8),
          const Tooltip(
            message:
                '6 categorias são exibidas por padrão.\nDigite para pesquisar outras.',
            child: Icon(FontAwesomeIcons.circleQuestion),
          ),
        ],
      ),
    );
  }

  Widget retornarContagemItens() {
    if (textoPesquisa.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${categoriasEmExibicao.length} resultado(s) para "$textoPesquisa"',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
    );
  }

  Widget retornarGridCategorias(List<Categoria> lista) {
    if (lista.isEmpty) {
      return Center(
        child: Text(
          textoPesquisa.isEmpty
              ? 'Nenhuma categoria disponível.'
              : 'Nenhum resultado para "$textoPesquisa"',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: lista.length,
      itemBuilder: (context, index) => retornarCardCategorias(lista[index]),
    );
  }

  Widget retornarCardCategorias(Categoria categoria) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (categoria.icone != null) Icon(categoria.icone, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    categoria.nome,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                categoria.descricao,
                style: const TextStyle(fontSize: 12),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PesquisaEmpresaPage(categoria: categoria),
                ),
              ),
              child: const Text('Selecionar'),
            ),
          ],
        ),
      ),
    );
  }
}
