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
  ConsumerState<MenuPrincipalPage> createState() {
    return MenuPrincipalWidgetState();
  }
}

class MenuPrincipalWidgetState extends ConsumerState<MenuPrincipalPage> {
  late Future<List<Categoria>> listaCategoriasFuture;
  List<Categoria> totalCategorias = [];
  List<Categoria> categoriasEmExibicao = [];
  String textoPesquisa = '';

  @override
  void initState() {
    super.initState();
    listaCategoriasFuture = _carregarCategorias();
  }

  Future<List<Categoria>> _carregarCategorias() async {
    final categorias =
        await ref.read(categoriaRepositoryProvider).getCategoriasAtivas();
    totalCategorias = categorias;
    categoriasEmExibicao = categorias.take(6).toList();
    return categorias;
  }

  void atualizarCategoriasEmExibicao(String texto) {
    textoPesquisa = texto;

    if (textoPesquisa.isEmpty) {
      setState(() {
        categoriasEmExibicao = totalCategorias.take(6).toList();
      });
    } else {
      final fuzzy = Fuzzy(
        totalCategorias.map((c) => c.nome).toList(),
        options: FuzzyOptions(
          findAllMatches: false,
          threshold: 0.3,
          distance: 50,
          minMatchCharLength: 2,
        ),
      );

      final resultado = fuzzy.search(textoPesquisa);
      final categoriasEncontradas = resultado
          .map((r) => totalCategorias.firstWhere((c) => c.nome == r.item))
          .toList();

      setState(() {
        categoriasEmExibicao = categoriasEncontradas;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.menuPrincipal(),
      drawer: const MenuLateralWidget(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    cabecalho(),
                    const SizedBox(height: 12),
                    barraPesquisa(),
                    const SizedBox(height: 12),
                    gridCategoria(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget cabecalho() {
    return const Column(
      children: [
        Text(
          'Bem-vindo ao Pegue o Doce! \n Escolha uma categoria',
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

  Widget barraPesquisa() {
    return SearchBar(
      hintText: 'Pesquisar por categoria',
      leading: const Icon(Icons.search),
      onChanged: atualizarCategoriasEmExibicao,
      trailing: const [
        Tooltip(
          message:
              '6 categorias são exibidas por padrão.\nDigite para pesquisar por outras categorias possíveis.',
          child: Icon(FontAwesomeIcons.circleQuestion),
        ),
      ],
    );
  }

  Widget gridCategoria() {
    return FutureBuilder<List<Categoria>>(
      future: listaCategoriasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar categorias.'));
        } else if (snapshot.hasData) {
          if (categoriasEmExibicao.isEmpty) {
            return const Center(child: Text('Nenhuma categoria encontrada.'));
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
            itemCount: categoriasEmExibicao.length,
            itemBuilder: (context, index) {
              return cardCategoria(categoriasEmExibicao[index]);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget cardCategoria(Categoria categoria) {
    return Card(
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
                softWrap: true,
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        PesquisaEmpresaPage(categoria: categoria),
                  ),
                );
              },
              child: const Text('Selecionar'),
            ),
          ],
        ),
      ),
    );
  }
}
