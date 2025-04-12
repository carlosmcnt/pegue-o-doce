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
  late Future<List<Categoria>> listaCategorias;
  List<Categoria> categoriasEmExibicao = [];
  List<Categoria> totalCategorias = [];
  String textoPesquisa = '';

  @override
  void initState() {
    super.initState();
    listaCategorias =
        ref.read(categoriaRepositoryProvider).getCategoriasAtivas();
    setState(() {
      textoPesquisa = '';
      categoriasEmExibicao = totalCategorias.take(5).toList();
    });
  }

  void atualizarCategoriasEmExibicao(String textoPesquisa) {
    if (textoPesquisa.isEmpty) {
      setState(() {
        categoriasEmExibicao = totalCategorias.take(10).toList();
      });
    } else {
      final buscaFuzzy = Fuzzy(
        totalCategorias.map((categoria) => categoria.nome).toList(),
        options: FuzzyOptions(findAllMatches: true, threshold: 0.6),
      );
      final listaFiltrada = buscaFuzzy.search(textoPesquisa);

      final categoriasEncontradas = listaFiltrada
          .map((resultado) => totalCategorias.firstWhere(
                (categoria) => categoria.nome == resultado.item,
              ))
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: FutureBuilder(
            future: listaCategorias,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erro: ${snapshot.error}');
              } else {
                totalCategorias = snapshot.data!;
                totalCategorias.sort((a, b) => a.nome.compareTo(b.nome));
                if (categoriasEmExibicao.isEmpty) {
                  categoriasEmExibicao = totalCategorias.take(5).toList();
                }
                return Column(
                  children: [
                    SearchBar(
                      hintText: 'Pesquisar por categoria',
                      leading: const Icon(Icons.search),
                      onChanged: (texto) {
                        setState(() {
                          textoPesquisa = texto;
                          atualizarCategoriasEmExibicao(texto);
                        });
                      },
                      trailing: const [
                        Tooltip(
                          message: 'As primeiras 5 categorias são exibidas. \n'
                              'Digite para pesquisar por outras categorias possíveis.',
                          child: Icon(
                            FontAwesomeIcons.circleQuestion,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: categoriasEmExibicao.length,
                        itemBuilder: (context, index) {
                          final categoria = categoriasEmExibicao[index];
                          return cardLayout(categoria);
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
      drawer: const MenuLateralWidget(),
    );
  }

  Widget cardLayout(Categoria categoria) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: categoria.icone != null ? Icon(categoria.icone) : null,
        title: Text(categoria.nome),
        subtitle: Text(categoria.descricao),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PesquisaEmpresaPage(categoria: categoria),
            ),
          );
        },
      ),
    );
  }
}
