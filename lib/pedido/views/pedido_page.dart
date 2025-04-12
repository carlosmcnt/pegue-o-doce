import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:flutter_cart/model/cart_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/pedido/controllers/encomenda_controller.dart';
import 'package:pegue_o_doce/pedido/models/item_pedido.dart';
import 'package:pegue_o_doce/pedido/views/carrinho_page.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:pegue_o_doce/utils/tema.dart';

class PedidoPage extends ConsumerStatefulWidget {
  final Empresa empresa;

  const PedidoPage({super.key, required this.empresa});

  @override
  ConsumerState<PedidoPage> createState() {
    return PedidoPageState();
  }
}

class PedidoPageState extends ConsumerState<PedidoPage> {
  Empresa get empresa => widget.empresa;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _observacaoController = TextEditingController();
  List<ItemPedido> itensSelecionados = [];
  Map<String, int> selecionados = {};
  List<Produto> produtos = [];
  FlutterCart carrinho = FlutterCart();
  double precoTotal = 0;

  void atualizarQuantidade(String produtoId, int delta) {
    setState(() {
      final item = itensSelecionados.firstWhere(
        (i) => i.produtoId == produtoId,
        orElse: () => ItemPedido(id: null, produtoId: produtoId, quantidade: 0),
      );

      if (item.id == null) {
        itensSelecionados.add(
            ItemPedido(id: produtoId, produtoId: produtoId, quantidade: delta));
      } else {
        item.quantidade += delta;
        if (item.quantidade <= 0) {
          itensSelecionados.removeWhere((i) => i.produtoId == produtoId);
        }
      }
    });
  }

  void verificarItensNoCarrinho() {
    List<CartModel> itensCarrinho = carrinho.cartItemsList;
    if (itensCarrinho.isEmpty) {
      return;
    }
    for (var item in itensCarrinho) {
      final produto = produtos.firstWhere((p) => p.id == item.productId,
          orElse: () => Produto.empty(empresa.id!));
      if (produto.id != null) {
        itensSelecionados.add(ItemPedido(
          id: produto.id,
          produtoId: produto.id,
          quantidade: item.quantity,
        ));
      }
    }
    precoTotal = 0;
  }

  double obterPrecoTotal(List<ItemPedido> itensSelecionados) {
    return itensSelecionados.fold(0, (soma, item) {
      final produto = produtos.firstWhere((p) => p.id == item.produtoId);
      return soma + (produto.valorUnitario * item.quantidade);
    });
  }

  @override
  void initState() {
    super.initState();
    verificarItensNoCarrinho();
  }

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.descricaoAcoes(
        "Pedido - ${empresa.nomeFantasia}",
        [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      "Selecione os produtos desejados e adiciona uma observação desejada:",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: FutureBuilder<List<Produto>>(
                      future: ref
                          .read(encomendaControllerProvider.notifier)
                          .listarProdutos(widget.empresa.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Erro: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          produtos = snapshot.data!;
                          return retornarListaProdutos();
                        } else {
                          return const Text('Nenhum produto encontrado.');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: TextFormField(
                      controller: _observacaoController,
                      decoration: InputDecoration(
                        labelText: 'Observação:',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(FontAwesomeIcons.comment),
                      ),
                      maxLines: null, // Set this
                      expands: true, // and this
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Total: R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(obterPrecoTotal(itensSelecionados))}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: MediaQuery.of(context).size.width * 0.05,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text("Adicionar ao Carrinho"),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (itensSelecionados.isNotEmpty) {
                              for (var item in itensSelecionados) {
                                carrinho.addToCart(
                                  cartModel: CartModel(
                                    productId: item.produtoId!,
                                    productName: produtos
                                        .firstWhere(
                                            (p) => p.id == item.produtoId)
                                        .sabor,
                                    quantity: item.quantidade,
                                    variants: [],
                                    productDetails: produtos
                                        .firstWhere(
                                            (p) => p.id == item.produtoId)
                                        .empresaId,
                                  ),
                                );
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CarrinhoPage(),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 16, height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text("Limpar Selecionados"),
                        onPressed: () {
                          setState(() {
                            itensSelecionados.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget retornarListaProdutos() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: produtos.length,
      itemBuilder: (context, index) {
        final produto = produtos[index];
        final item = itensSelecionados.firstWhere(
          (i) => i.produtoId == produto.id,
          orElse: () =>
              ItemPedido(id: null, produtoId: produto.id, quantidade: 0),
        );
        return SizedBox(
          height: 80,
          child: ListTile(
            title: Text(produto.sabor),
            subtitle: Text(
                FormatadorMoedaReal.formatarValorReal(produto.valorUnitario)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(FontAwesomeIcons.minus),
                  onPressed: item.quantidade > 0
                      ? () => atualizarQuantidade(produto.id!, -1)
                      : null,
                ),
                Text("${item.quantidade}"),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.plus),
                  onPressed: () => atualizarQuantidade(produto.id!, 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
