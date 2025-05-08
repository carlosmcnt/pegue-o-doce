import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/pedido/controllers/encomenda_controller.dart';
import 'package:pegue_o_doce/pedido/models/item_pedido.dart';
import 'package:pegue_o_doce/pedido/models/pedido.dart';
import 'package:pegue_o_doce/pedido/models/status_pedido.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/usuario/models/usuario.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:pegue_o_doce/utils/notificacao_utils.dart';
import 'package:pegue_o_doce/utils/widget_utils.dart';
import 'package:pegue_o_doce/utils/tema.dart';

class EncomendaPage extends ConsumerStatefulWidget {
  final Empresa empresa;

  const EncomendaPage({super.key, required this.empresa});

  @override
  ConsumerState<EncomendaPage> createState() {
    return EncomendaPageState();
  }
}

class EncomendaPageState extends ConsumerState<EncomendaPage> {
  Empresa get empresa => widget.empresa;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _observacaoController = TextEditingController();
  double valorTotal = 0.0;
  String? tipoSelecionado;
  List<Produto> produtos = [];
  List<ItemPedido> itensSelecionados = [];
  String? localEntregaSelecionado;

  int get quantidadeTotal =>
      itensSelecionados.fold(0, (total, p) => total + p.quantidade);

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
      valorTotal = itensSelecionados.fold(
          0.0,
          (total, item) =>
              total +
              (produtos
                      .firstWhere((p) => p.id == item.produtoId)
                      .valorUnitario *
                  item.quantidade));
    });
  }

  Future<void> listarProdutosPorTipo(String tipo) async {
    produtos = await ref
        .read(encomendaControllerProvider.notifier)
        .obterProdutosPorTipo(tipo);
  }

  Future<void> enviarEncomenda(
      List<ItemPedido> itens, BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      Navigator.pop(context);
      return;
    }

    Usuario usuarioVendedor = await ref
        .read(encomendaControllerProvider.notifier)
        .obterUsuarioPorId(empresa.usuarioId);

    final pedido = Pedido(
      usuarioClienteId: await ref
          .read(encomendaControllerProvider.notifier)
          .obterIdUsuarioLogado(),
      usuarioVendedorId: empresa.usuarioId,
      itensPedido: itens,
      status: StatusPedido.FINALIZADO.nome,
      dataPedido: Timestamp.now(),
      valorTotal: valorTotal,
      observacao: _observacaoController.text,
      localRetirada: localEntregaSelecionado!,
      isEncomenda: true,
      dataUltimaAlteracao: Timestamp.now(),
      motivoCancelamento: null,
    );

    await ref.read(encomendaControllerProvider.notifier).inserirPedido(pedido);

    NotificacaoUtils.enviarNotificacaoPush(token: usuarioVendedor.token!);

    if (!context.mounted) return;

    Navigator.pop(context);

    WidgetUtils.showSnackbar(
      mensagem: 'Encomenda enviada com sucesso!',
      context: context,
      erro: false,
    );

    limparCampos();
  }

  @override
  void initState() {
    super.initState();
  }

  void limparCampos() {
    setState(() {
      valorTotal = 0.0;
      itensSelecionados.clear();
      _observacaoController.clear();
      localEntregaSelecionado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool podeEnviar = quantidadeTotal >= 10 && valorTotal > 0;

    return Scaffold(
      appBar: Tema.padrao("Realizar Encomenda"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  WidgetUtils.textoInformacao(
                      'Selecione o tipo de produto, a quantidade e o local de retirada para realizar a encomenda. O pagamento será feito na retirada.'),
                  const SizedBox(height: 5),
                  if (quantidadeTotal < 10)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'É necessário selecionar no mínimo 10 unidades para realizar a encomenda.',
                              style: TextStyle(color: Colors.orange.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Flexible(
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              WidgetSpan(
                                  child: Icon(FontAwesomeIcons.clipboardList)),
                              WidgetSpan(child: SizedBox(width: 8)),
                              TextSpan(
                                text: 'Tipo do produto:',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      carregarTiposDeProduto(ref),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (tipoSelecionado != null) carregarProdutosPorTipo(ref),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(FontAwesomeIcons.locationDot, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Local de Retirada:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: localEntregaSelecionado,
                        onChanged: (String? novoTipo) {
                          setState(() {
                            localEntregaSelecionado = novoTipo;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                        items: empresa.locaisEntrega
                            .map((local) => DropdownMenuItem<String>(
                                  value: local.nome,
                                  child: Text(
                                    local.nome,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12.0),
                        ),
                      ),
                    ],
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
                      maxLines: null,
                      maxLength: 200,
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          FormatadorMoedaReal.formatarValorReal(valorTotal),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: podeEnviar
                                  ? () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            dialogoConfirmacao(context),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              icon: const Icon(FontAwesomeIcons.check),
                              label: const Text("Enviar"),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                limparCampos();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              icon: const Icon(FontAwesomeIcons.trash),
                              label: const Text("Limpar"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget carregarTiposDeProduto(WidgetRef ref) {
    return FutureBuilder<List<String>>(
      future:
          ref.read(encomendaControllerProvider.notifier).obterTiposDeProduto(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Erro ao carregar tipos');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Nenhum tipo disponível');
        } else {
          return DropdownMenu<String>(
            initialSelection: tipoSelecionado,
            onSelected: (String? novoTipo) {
              setState(() {
                tipoSelecionado = novoTipo;
                limparCampos();
              });
              if (novoTipo != null) {
                listarProdutosPorTipo(novoTipo);
              }
            },
            dropdownMenuEntries: snapshot.data!
                .map((tipo) => DropdownMenuEntry<String>(
                      value: tipo,
                      label: tipo,
                    ))
                .toList(),
          );
        }
      },
    );
  }

  Widget carregarProdutosPorTipo(WidgetRef ref) {
    return FutureBuilder<List<Produto>>(
      future: ref
          .read(encomendaControllerProvider.notifier)
          .obterProdutosPorTipo(tipoSelecionado!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Erro ao carregar produtos');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Nenhum produto disponível');
        } else {
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
                    subtitle: Text(FormatadorMoedaReal.formatarValorReal(
                        produto.valorUnitario)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.minus),
                          onPressed: item.quantidade > 0
                              ? () => atualizarQuantidade(produto.id!, -1)
                              : null,
                        ),
                        SizedBox(
                          width: 40,
                          height: 30,
                          child: TextFormField(
                            controller: TextEditingController(
                                text: item.quantidade.toString()),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 5),
                              border: OutlineInputBorder(),
                            ),
                            onFieldSubmitted: (value) {
                              final novaQtd = int.tryParse(value);
                              if (novaQtd != null && novaQtd >= 0) {
                                atualizarQuantidade(
                                    produto.id!, novaQtd - item.quantidade);
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.plus),
                          onPressed: () => atualizarQuantidade(produto.id!, 1),
                        ),
                      ],
                    ),
                  ));
            },
          );
        }
      },
    );
  }

  AlertDialog dialogoConfirmacao(BuildContext context) {
    return AlertDialog(
      title: const Icon(FontAwesomeIcons.circleQuestion,
          color: Color.fromARGB(255, 190, 173, 19)),
      content: const Text('Deseja confirmar o envio da encomenda?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            enviarEncomenda(itensSelecionados, context);
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
