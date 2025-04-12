import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:flutter_cart/model/cart_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/pedido/controllers/encomenda_controller.dart';
import 'package:pegue_o_doce/pedido/models/item_pedido.dart';
import 'package:pegue_o_doce/pedido/models/pedido.dart';
import 'package:pegue_o_doce/pedido/models/status_pedido.dart';
import 'package:pegue_o_doce/pedido/views/historico_pedido_page.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:pegue_o_doce/utils/tema.dart';

class CarrinhoPage extends ConsumerStatefulWidget {
  const CarrinhoPage({super.key});

  @override
  ConsumerState<CarrinhoPage> createState() {
    return CarrinhoPageState();
  }
}

class CarrinhoPageState extends ConsumerState<CarrinhoPage> {
  FlutterCart carrinho = FlutterCart();
  List<ItemPedido> itensSelecionados = [];
  String? empresaId;
  double precoTotal = 0;

  List<CartModel> get produtosNoCarrinho {
    return carrinho.cartItemsList;
  }

  List<ItemPedido> get listaItensCarrinho => produtosNoCarrinho
      .map((item) => ItemPedido(
            produtoId: item.productId,
            quantidade: item.quantity,
          ))
      .toList();

  Future<List<Produto>> get produtos async {
    List<String> ids = [];
    for (var item in listaItensCarrinho) {
      if (item.produtoId != null) {
        ids.add(item.produtoId!);
      }
    }
    if (ids.isNotEmpty) {
      return await ref
          .read(encomendaControllerProvider.notifier)
          .obterProdutosPorIds(ids);
    }
    return [];
  }

  Future<String> get idEmpresa async {
    return await ref
        .read(encomendaControllerProvider.notifier)
        .obterEmpresaPorIdProduto(produtosNoCarrinho.first.productId);
  }

  Future<String> get idUsuarioLogado async {
    return await ref
        .read(encomendaControllerProvider.notifier)
        .obterIdUsuarioLogado();
  }

  double calcularPrecoTotal(List<Produto> produtos) {
    double total = 0;
    for (var item in produtos) {
      final produtoCarrinho = produtosNoCarrinho
          .firstWhere((produto) => produto.productId == item.id);
      total += item.valorUnitario * produtoCarrinho.quantity;
    }
    precoTotal = total;
    return total;
  }

  Future<void> enviarEncomenda(
      List<ItemPedido> itens, BuildContext context) async {
    final pedido = Pedido(
      usuarioClienteId: await idUsuarioLogado,
      usuarioVendedorId: await idEmpresa,
      itensPedido: itens,
      status: StatusPedido.PENDENTE.nome,
      dataPedido: Timestamp.now(),
      valorTotal: precoTotal,
      observacao: '',
      isEncomenda: false,
      dataUltimaAlteracao: Timestamp.now(),
      motivoCancelamento: null,
    );

    await ref.read(encomendaControllerProvider.notifier).inserirPedido(pedido);

    if (!context.mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.descricaoAcoes("Carrinho de Compras", []),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: carrinho.cartLength == 0
            ? const Center(
                child: Text(
                  'Carrinho vazio',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Resumo do Pedido",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'NOME DA EMPRESA AQUI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FutureBuilder<List<Produto>>(
                          future: produtos,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Erro ao carregar produtos'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('Nenhum produto encontrado'));
                            }
                            final produtos = snapshot.data!;
                            return Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(columns: const [
                                    DataColumn(
                                      label: Text('Produto'),
                                    ),
                                    DataColumn(
                                      label: Text('Val. Unitário'),
                                    ),
                                    DataColumn(
                                      label: Text('Quantidade'),
                                    ),
                                  ], rows: [
                                    for (var produto in produtos)
                                      DataRow(cells: [
                                        DataCell(Text(produto.sabor)),
                                        DataCell(Text(FormatadorMoedaReal
                                            .formatarValorReal(
                                                produto.valorUnitario))),
                                        DataCell(Text(
                                            "${produtosNoCarrinho.firstWhere((item) => item.productId == produto.id).quantity}")),
                                      ]),
                                  ]),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  FormatadorMoedaReal.formatarValorReal(
                                      calcularPrecoTotal(produtos)),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          carrinho.clearCart();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(FontAwesomeIcons.trashCan),
                        label: const Text("Limpar Carrinho"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (produtosNoCarrinho.isNotEmpty) {
                            carrinho.clearCart();
                            enviarEncomenda(listaItensCarrinho, context);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const HistoricoPedidoPage(
                                  isHistoricoEmpresa: false,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Esvaziando o carrinho...'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(FontAwesomeIcons.check),
                        label: const Text("Gerar Pedido"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
