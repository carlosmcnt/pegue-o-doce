import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:flutter_cart/model/cart_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/pedido/controllers/encomenda_controller.dart';
import 'package:pegue_o_doce/pedido/models/item_pedido.dart';
import 'package:pegue_o_doce/pedido/views/carrinho_page.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:pegue_o_doce/utils/tema.dart';
import 'package:pegue_o_doce/utils/widget_utils.dart';

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
  List<ItemPedido> itensSelecionados = [];
  List<Produto> produtos = [];
  FlutterCart carrinho = FlutterCart();

  void sincronizarCarrinho() {
    final noCarrinho = carrinho.cartItemsList;
    itensSelecionados = [];
    for (var cartItem in noCarrinho) {
      final p = produtos.firstWhere(
        (p) => p.id == cartItem.productId,
        orElse: () => Produto.empty(empresa.id!),
      );
      if (p.id != null) {
        itensSelecionados.add(
          ItemPedido(
            id: p.id,
            produtoId: p.id,
            quantidade: cartItem.quantity,
          ),
        );
      }
    }
    setState(() {});
  }

  void atualizarQuantidade(String produtoId, int delta) {
    setState(() {
      final indice =
          itensSelecionados.indexWhere((i) => i.produtoId == produtoId);
      if (indice == -1 && delta > 0) {
        itensSelecionados.add(
            ItemPedido(id: produtoId, produtoId: produtoId, quantidade: delta));
      } else if (indice != -1) {
        itensSelecionados[indice].quantidade += delta;
        if (itensSelecionados[indice].quantidade <= 0) {
          itensSelecionados.removeAt(indice);
        }
      }
    });
  }

  double get precoTotal => itensSelecionados.fold(0, (sum, item) {
        final p = produtos.firstWhere((p) => p.id == item.produtoId);
        return sum + (p.valorUnitario * item.quantidade);
      });

  void adicionarAoCarrinho() {
    for (var it in itensSelecionados) {
      final p = produtos.firstWhere((p) => p.id == it.produtoId);
      carrinho.addToCart(
        cartModel: CartModel(
          productId: p.id!,
          productName: '${p.tipo} - ${p.sabor}',
          quantity: it.quantidade,
          variants: [],
          productDetails: p.empresaId,
        ),
      );
    }
    WidgetUtils.showSnackbar(
      mensagem: 'Item(s) adicionado(s) ao carrinho',
      context: context,
      erro: false,
    );
    sincronizarCarrinho();
    itensSelecionados.clear();
  }

  void verificarCarrinhoItemEmpresa() {
    final itensCarrinho = carrinho.cartItemsList;
    final sameEmpresa = itensCarrinho.isEmpty ||
        itensCarrinho.first.productDetails == empresa.id;
    if (!sameEmpresa) {
      showDialog(
        context: context,
        builder: (context) {
          return dialogLimparCarrinho(context);
        },
      );
    } else {
      adicionarAoCarrinho();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.padrao("Realizar Pedido"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: WidgetUtils.textoInformacao(
                      'Selecione quantas unidades desejar e clique em "Adicionar ao Carrinho". '
                      'Você pode navegar por várias páginas do aplicativo; o carrinho mantém tudo aqui.'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<Produto>>(
                    future: ref
                        .read(encomendaControllerProvider.notifier)
                        .listarProdutos(widget.empresa.id!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Erro: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        produtos = snapshot.data!;
                        return retornarListaProdutos();
                      } else {
                        return const Text('Nenhum produto encontrado');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Total: ${FormatadorMoedaReal.formatarValorReal(precoTotal)}",
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
                      label: Text("Adicionar ao Carrinho",
                          style: TextStyle(
                              color:
                                  Theme.of(context).scaffoldBackgroundColor)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: itensSelecionados.isEmpty
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                verificarCarrinhoItemEmpresa();
                              }
                            },
                    ),
                    const SizedBox(width: 16, height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: Text("Limpar Selecionados",
                          style: TextStyle(
                              color:
                                  Theme.of(context).scaffoldBackgroundColor)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
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
    );
  }

  void mostrarPopupCarrinho() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Meu Carrinho'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (carrinho.cartItemsList.isEmpty)
                const Center(
                    child:
                        Text('Carrinho vazio', style: TextStyle(fontSize: 20)))
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: carrinho.cartItemsList.length,
                    itemBuilder: (_, i) {
                      final it = carrinho.cartItemsList[i];
                      return ListTile(
                        dense: true,
                        title: Text(it.productName),
                        subtitle: Text('Qtd: ${it.quantity}'),
                      );
                    },
                  ),
                ),
              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: ${FormatadorMoedaReal.formatarValorReal(carrinho.cartItemsList.fold(0.0, (total, item) {
                    final produto = produtos.firstWhere(
                      (p) => p.id == item.productId,
                      orElse: () => Produto.empty(empresa.id!),
                    );
                    return total + (produto.valorUnitario * item.quantity);
                  }))}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CarrinhoPage()));
            },
            child: const Text('Ver Carrinho'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  AlertDialog dialogLimparCarrinho(BuildContext context) {
    return AlertDialog(
      title: const Icon(FontAwesomeIcons.trash, color: Colors.red),
      content: const Text(
          'O carrinho contém itens de outra empresa. Deseja limpar e adicionar estes?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            carrinho.clearCart();
            Navigator.pop(context);
            adicionarAoCarrinho();
          },
          child: const Text('Limpar e Adicionar'),
        ),
      ],
    );
  }

  Widget retornarListaProdutos() {
    final cols = MediaQuery.of(context).size.width > 600 ? 3 : 2;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: produtos.length,
      itemBuilder: (c, i) {
        final p = produtos[i];
        final qtd = itensSelecionados
            .firstWhere((it) => it.produtoId == p.id,
                orElse: () =>
                    ItemPedido(id: null, produtoId: p.id, quantidade: 0))
            .quantidade;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${p.tipo} sabor - ${p.sabor}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(FormatadorMoedaReal.formatarValorReal(p.valorUnitario)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                          qtd > 0 ? () => atualizarQuantidade(p.id!, -1) : null,
                    ),
                    SizedBox(
                      width: 40,
                      height: 30,
                      child: TextFormField(
                        controller: TextEditingController(
                            text: qtd > 0 ? qtd.toString() : ''),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (value) {
                          final novaQtd = int.tryParse(value);
                          if (novaQtd != null && novaQtd >= 0) {
                            atualizarQuantidade(p.id!, novaQtd - qtd);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => atualizarQuantidade(p.id!, 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
