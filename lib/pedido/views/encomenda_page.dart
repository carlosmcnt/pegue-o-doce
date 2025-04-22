import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/pedido/controllers/encomenda_controller.dart';
import 'package:pegue_o_doce/pedido/models/item_pedido.dart';
import 'package:pegue_o_doce/pedido/models/pedido.dart';
import 'package:pegue_o_doce/pedido/models/status_pedido.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/utils/email_util.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:pegue_o_doce/utils/tema.dart';
import 'package:file_picker/file_picker.dart';

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
  final TextEditingController _chavePixController = TextEditingController();
  PlatformFile? arquivoSelecionado;
  String? tipoSelecionado;
  List<Produto> produtos = [];
  List<ItemPedido> itensSelecionados = [];
  String? localEntregaSelecionado;

  Future<void> selecionarArquivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        arquivoSelecionado = result.files.first;
      });
    }
  }

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

  double get precoTotal {
    return itensSelecionados.fold(0, (soma, item) {
      final produto = produtos.firstWhere((p) => p.id == item.produtoId);
      return soma + (produto.valorUnitario * item.quantidade);
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

    if (arquivoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um arquivo de comprovante de pagamento'),
        ),
      );
      Navigator.pop(context);
      return;
    }

    final pedido = Pedido(
      usuarioClienteId: await ref
          .read(encomendaControllerProvider.notifier)
          .obterIdUsuarioLogado(),
      usuarioVendedorId: empresa.usuarioId,
      itensPedido: itens,
      status: StatusPedido.PENDENTE.nome,
      dataPedido: Timestamp.now(),
      valorTotal: precoTotal,
      observacao: _observacaoController.text,
      isEncomenda: true,
      dataUltimaAlteracao: Timestamp.now(),
      motivoCancelamento: null,
    );

    await ref.read(encomendaControllerProvider.notifier).inserirPedido(pedido);

    if (!context.mounted) return;

    await EmailUtil.enviarEmailEncomenda(
      context,
      localEntregaSelecionado!,
      pedido,
      produtos,
      ref,
    );
  }

  @override
  void initState() {
    super.initState();
    _chavePixController.text = empresa.chavePix;
  }

  void limparCampos() {
    setState(() {
      itensSelecionados.clear();
      arquivoSelecionado = null;
      _observacaoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.descricaoAcoes(
        "Realizar Encomenda",
        [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
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
                  TextFormField(
                    controller: _chavePixController,
                    decoration: InputDecoration(
                      labelText: 'Chave PIX:',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(FontAwesomeIcons.qrcode),
                      suffixIcon: IconButton(
                        icon: const Icon(FontAwesomeIcons.copy),
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: _chavePixController.text));

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chave PIX copiada!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Flexible(
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              WidgetSpan(child: Icon(FontAwesomeIcons.filePdf)),
                              WidgetSpan(child: SizedBox(width: 8)),
                              TextSpan(
                                text: 'Comprovante de Pagamento:',
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
                      ElevatedButton.icon(
                        icon: const Icon(FontAwesomeIcons.fileArrowUp),
                        onPressed: selecionarArquivo,
                        label: const Text("Selecionar Arquivo"),
                      ),
                      const SizedBox(width: 5),
                      if (arquivoSelecionado != null)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Arquivo: ${arquivoSelecionado!.name}"),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    children: [
                      const Text('Selecione um local de entrega:',
                          style: TextStyle(
                            fontSize: 16,
                          )),
                      const SizedBox(width: 16),
                      DropdownMenu<String>(
                        initialSelection: null,
                        onSelected: (String? novoTipo) {
                          setState(() {
                            localEntregaSelecionado = novoTipo;
                          });
                        },
                        dropdownMenuEntries: empresa.locaisEntrega
                            .map((local) => DropdownMenuEntry<String>(
                                  value: local,
                                  label: local,
                                ))
                            .toList(),
                      ),
                      const SizedBox(width: 16),
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          FormatadorMoedaReal.formatarValorReal(precoTotal),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Tooltip(
                          message: precoTotal > 0
                              ? "Preencha os campos e envie o pedido"
                              : "Selecione ao menos um produto",
                          child: ElevatedButton.icon(
                            onPressed: precoTotal > 0
                                ? () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          dialogoConfirmacao(context),
                                    );
                                  }
                                : null,
                            icon: const Icon(FontAwesomeIcons.check),
                            label: const Text("Enviar"),
                          ),
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
