import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:flutter_cart/model/cart_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/menu/views/menu_lateral.dart';
import 'package:pegue_o_doce/pedido/controllers/encomenda_controller.dart';
import 'package:pegue_o_doce/pedido/models/item_pedido.dart';
import 'package:pegue_o_doce/pedido/models/pedido.dart';
import 'package:pegue_o_doce/pedido/models/status_pedido.dart';
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
  double precoTotal = 0;
  String? localEntregaSelecionado;
  final TextEditingController _observacaoController = TextEditingController();

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

  Future<String> get idUsuarioLogado async {
    return await ref
        .read(encomendaControllerProvider.notifier)
        .obterIdUsuarioLogado();
  }

  Future<Empresa> get empresa async {
    return await ref
        .read(encomendaControllerProvider.notifier)
        .obterEmpresaPorIdProduto(produtosNoCarrinho.first.productId);
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
      usuarioVendedorId: await empresa.then((value) => value.usuarioId),
      itensPedido: itens,
      status: StatusPedido.PENDENTE.nome,
      dataPedido: Timestamp.now(),
      valorTotal: precoTotal,
      observacao: _observacaoController.text,
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
      appBar: Tema.padrao("Carrinho de Compras"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: carrinho.cartLength == 0
            ? const Center(
                child: Text(
                  'Carrinho vazio',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Resumo do Pedido",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<List<Produto>>(
                      future: produtos,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return const Center(
                              child: Text('Erro ao carregar produtos.'));
                        }
                        final produtosList = snapshot.data!;
                        return ListView.builder(
                          itemCount: produtosNoCarrinho.length,
                          itemBuilder: (context, index) {
                            final item = produtosNoCarrinho[index];
                            final produto = produtosList
                                .firstWhere((p) => p.id == item.productId);
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                    '${produto.tipo} - ${produto.sabor}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Valor unitário: ${FormatadorMoedaReal.formatarValorReal(produto.valorUnitario)}'),
                                    Text('Quantidade: ${item.quantity}'),
                                  ],
                                ),
                                trailing: Text(
                                  FormatadorMoedaReal.formatarValorReal(
                                      produto.valorUnitario * item.quantity),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Selecione um local de entrega:',
                          style: TextStyle(
                            fontSize: 16,
                          )),
                      const SizedBox(width: 16),
                      FutureBuilder<Empresa>(
                        future: empresa,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Text(
                              'Erro ao carregar locais de entrega.',
                              style: TextStyle(fontSize: 16),
                            );
                          }
                          final locaisEntrega = snapshot.data!.locaisEntrega;
                          return DropdownMenu<String>(
                            initialSelection: localEntregaSelecionado,
                            width: MediaQuery.of(context).size.width,
                            leadingIcon: const Icon(
                              FontAwesomeIcons.locationDot,
                              color: Colors.purple,
                            ),
                            onSelected: (String? novoTipo) {
                              setState(() {
                                localEntregaSelecionado = novoTipo;
                              });
                            },
                            dropdownMenuEntries: locaisEntrega
                                .map((local) => DropdownMenuEntry<String>(
                                      value: local,
                                      label: local,
                                    ))
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _observacaoController,
                    decoration: InputDecoration(
                      labelText: 'Observação:',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(FontAwesomeIcons.comment),
                    ),
                    maxLines: null,
                    expands: true,
                    maxLength: 200,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: FutureBuilder<List<Produto>>(
                      future: produtos,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return const Text(
                            'Erro ao calcular o total.',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          );
                        }
                        final total = calcularPrecoTotal(snapshot.data!);
                        return Text(
                          'Total: ${FormatadorMoedaReal.formatarValorReal(total)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            produtosNoCarrinho.clear();
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Carrinho limpo!"),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(FontAwesomeIcons.trashCan),
                        label: const Text("Limpar Carrinho"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Pedido enviado!"),
                            ),
                          );
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
      drawer: const MenuLateralWidget(),
    );
  }
}
