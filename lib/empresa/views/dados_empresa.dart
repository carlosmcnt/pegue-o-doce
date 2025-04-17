import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/empresa/controllers/dados_empresa_controller.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/empresa/views/empresa_edit_page.dart';
import 'package:pegue_o_doce/menu/views/menu_lateral.dart';
import 'package:pegue_o_doce/pedido/views/historico_pedido_page.dart';
import 'package:pegue_o_doce/produto/controllers/produto_list_controller.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/produto/views/produto_edit_page.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:pegue_o_doce/utils/tema.dart';

class DadosEmpresaPage extends ConsumerStatefulWidget {
  final Empresa empresa;

  const DadosEmpresaPage({super.key, required this.empresa});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return DadosEmpresaPageState();
  }
}

class DadosEmpresaPageState extends ConsumerState<DadosEmpresaPage> {
  Empresa get empresa => widget.empresa;

  @override
  void initState() {
    super.initState();
  }

  Map<String, List<Produto>> agruparProdutosPorTipo(List<Produto> produtos) {
    final listaAgrupados = <String, List<Produto>>{};
    for (final produto in produtos) {
      if (!listaAgrupados.containsKey(produto.tipo)) {
        listaAgrupados[produto.tipo] = [];
      }
      listaAgrupados[produto.tipo]!.add(produto);
    }
    return listaAgrupados;
  }

  void atualizarPagina() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DadosEmpresaPage(empresa: empresa),
      ),
    );
  }

  void abrirPaginaHistoricoPedido() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              const HistoricoPedidoPage(isHistoricoEmpresa: true)),
    );
  }

  void abrirPaginaIncluirEditarProduto() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProdutoEditPage(
          produto: Produto.empty(empresa.id!),
          empresa: empresa,
        ),
      ),
    );
  }

  void abrirPaginaEditarEmpresa() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmpresaEditPage(
          empresa: empresa,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listaProdutos = ref.watch(dadosEmpresaControllerProvider);

    return Scaffold(
      appBar: Tema.descricaoAcoes('Minha Empresa', []),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        empresa.nomeFantasia,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const WidgetSpan(
                                  child: Icon(FontAwesomeIcons.circleInfo,
                                      color: Colors.blue)),
                              const WidgetSpan(child: SizedBox(width: 10)),
                              TextSpan(
                                text: empresa.descricao,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.locationDot,
                                color: Colors.green),
                            Text(
                              'Locais de Entrega: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (var local in empresa.locaisEntrega)
                        Chip(
                          label: Text(local),
                        ),
                      const SizedBox(height: 20),
                      Wrap(
                        children: [
                          Container(
                            child: botaoAcaoEmpresa(
                              icon: FontAwesomeIcons.circlePlus,
                              label: 'Adicionar Produto',
                              onPressed: abrirPaginaIncluirEditarProduto,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            child: botaoAcaoEmpresa(
                              icon: FontAwesomeIcons.penToSquare,
                              label: 'Alterar Empresa',
                              onPressed: abrirPaginaEditarEmpresa,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            child: botaoAcaoEmpresa(
                              icon: FontAwesomeIcons.clockRotateLeft,
                              label: 'Histórico de Vendas',
                              onPressed: abrirPaginaHistoricoPedido,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              listaProdutos.when(data: (produtos) {
                final produtosAgrupados = agruparProdutosPorTipo(produtos);
                return ListView(
                  shrinkWrap: true,
                  children: produtosAgrupados.entries
                      .map(
                        (entry) => organizarProdutosPorTipo(
                            context, entry.key, entry.value),
                      )
                      .toList(),
                );
              }, loading: () {
                return const Center(child: CircularProgressIndicator());
              }, error: (error, stack) {
                return const Center(
                  child: Column(
                    children: [
                      Text('Erro ao carregar produtos'),
                    ],
                  ),
                );
              })
            ],
          ),
        ),
      ),
      drawer: const MenuLateralWidget(),
    );
  }

  Widget botaoAcaoEmpresa({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 50),
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  Widget organizarProdutosPorTipo(
      BuildContext context, String tipo, List<Produto> produtos) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tipo.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Column(
              children: produtos
                  .map(
                    (produto) => ListTile(
                      leading: const Icon(FontAwesomeIcons.box),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      title: Text(produto.sabor,
                          style: const TextStyle(fontSize: 20)),
                      subtitle: Text(
                          FormatadorMoedaReal.formatarValorReal(
                              produto.valorUnitario),
                          style: const TextStyle(fontSize: 16)),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProdutoEditPage(
                            produto: produto,
                            empresa: empresa,
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Excluir Produto'),
                              content: const Text(
                                  'Tem certeza que deseja excluir este produto?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    ref
                                        .read(produtoListControllerProvider
                                            .notifier)
                                        .deletarProduto(produto);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Produto excluído com sucesso!'),
                                      ),
                                    );

                                    atualizarPagina();
                                  },
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
