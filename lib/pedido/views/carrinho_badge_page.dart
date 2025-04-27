import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/pedido/controllers/encomenda_controller.dart';
import 'package:pegue_o_doce/pedido/views/carrinho_page.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarrinhoBadgeWidget extends ConsumerWidget {
  const CarrinhoBadgeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = FlutterCart();
    final totalItens =
        cart.cartItemsList.fold(0, (sum, item) => sum + item.quantity);

    return Badge(
      alignment: Alignment.bottomLeft,
      backgroundColor: Colors.green,
      label: Text(
        '$totalItens',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      isLabelVisible: totalItens > 0,
      child: IconButton(
        icon: const Icon(FontAwesomeIcons.cartShopping),
        onPressed: () async {
          final itens = cart.cartItemsList;

          final produtoController =
              ref.read(encomendaControllerProvider.notifier);
          final produtos = await produtoController
              .obterProdutosPorIds(itens.map((e) => e.productId).toList());

          double precoTotal = await produtoController.obterPrecoTotal(
              itens.map((e) => e.productId).toList(),
              itens.map((e) => e.quantity).toList());

          if (!context.mounted) return;

          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: const Text('Meu Carrinho'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (itens.isEmpty)
                        const Text('Seu carrinho está vazio')
                      else
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: itens.length,
                            itemBuilder: (_, i) {
                              final it = itens[i];
                              final produto = produtos.firstWhere(
                                (p) => p.id == it.productId,
                                orElse: () => Produto.empty(''),
                              );
                              return ListTile(
                                dense: true,
                                title:
                                    Text('${produto.tipo} - ${produto.sabor}'),
                                subtitle: Text('Qtd: ${it.quantity}'),
                              );
                            },
                          ),
                        ),
                      const Divider(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total: ${FormatadorMoedaReal.formatarValorReal(precoTotal)}',
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
                        MaterialPageRoute(
                          builder: (_) => const CarrinhoPage(),
                        ),
                      );
                    },
                    child: const Text('Ver Carrinho'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
