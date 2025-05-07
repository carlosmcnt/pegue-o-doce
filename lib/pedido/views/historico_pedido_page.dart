import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pegue_o_doce/menu/views/menu_lateral.dart';
import 'package:pegue_o_doce/pedido/controllers/historico_pedido_controller.dart';
import 'package:pegue_o_doce/pedido/models/item_pedido.dart';
import 'package:pegue_o_doce/pedido/models/pedido.dart';
import 'package:pegue_o_doce/pedido/models/status_pedido.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:pegue_o_doce/utils/gerador_codigo_pedido.dart';
import 'package:pegue_o_doce/utils/notificacao_utils.dart';
import 'package:pegue_o_doce/utils/snackbar_util.dart';
import 'package:pegue_o_doce/utils/tema.dart';

class HistoricoPedidoPage extends ConsumerStatefulWidget {
  const HistoricoPedidoPage({super.key, required this.isHistoricoEmpresa});
  final bool isHistoricoEmpresa;

  @override
  ConsumerState<HistoricoPedidoPage> createState() =>
      _HistoricoPedidoPageState();
}

class _HistoricoPedidoPageState extends ConsumerState<HistoricoPedidoPage> {
  List<Pedido> listaPedidosFinal = [];
  String statusSelecionado = "Todos";
  late List<String> listaStatus;
  bool isOrdenacaoDecrescente = true;
  int registrosPorPagina = 5;
  int paginaAtual = 1;
  final TextEditingController _motivoCancelamentoController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    listaStatus = StatusPedido.values.map((status) => status.nome).toList();
  }

  @override
  Widget build(BuildContext context) {
    final formatadorData = DateFormat('EEE, d MMMM yyyy', 'pt_BR');

    final pedidosAsync =
        ref.watch(historicoPedidoControllerProvider(widget.isHistoricoEmpresa));
    List<Pedido> listaPedidos = aplicarFiltros(pedidosAsync);

    return Scaffold(
      appBar: Tema.historicoPedido(
        widget.isHistoricoEmpresa
            ? "Histórico de Vendas"
            : "Histórico de Pedidos",
        [exibirFiltroStatus()],
      ),
      drawer: const MenuLateralWidget(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.isHistoricoEmpresa) exibirPainelVendedor(pedidosAsync),
            exibirPaginacaoOrdenacao(),
            const Divider(),
            Center(
              child: pedidosAsync.when(
                data: (lista) {
                  if (lista.isEmpty) {
                    return const Center(
                        child: Text(
                      "Nenhum pedido encontrado",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listaPedidos.length,
                    itemBuilder: (context, index) {
                      final pedido = listaPedidos[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatadorData.format(pedido.dataPedido.toDate()),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 5),
                            FutureBuilder<Map<String, String>>(
                              future: ref
                                  .read(historicoPedidoControllerProvider(
                                          widget.isHistoricoEmpresa)
                                      .notifier)
                                  .obterNomeClienteOuEmpresa(
                                      pedido.id!, widget.isHistoricoEmpresa),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasData) {
                                  return exibirCardPedido(
                                      pedido, snapshot.data!);
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text("Erro ao carregar pedidos: $error")),
              ),
            ),
            exibirPaginacao(),
          ],
        ),
      ),
    );
  }

  Widget exibirFiltroStatus() {
    return PopupMenuButton<String>(
      icon: const Icon(FontAwesomeIcons.filter),
      initialValue: statusSelecionado,
      onSelected: (String novoStatus) {
        setState(() {
          statusSelecionado = novoStatus;
        });
      },
      itemBuilder: (BuildContext context) {
        return listaStatus.map((String value) {
          return PopupMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList();
      },
    );
  }

  Widget exibirPaginacaoOrdenacao() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Row(
            children: [
              const Icon(FontAwesomeIcons.arrowDownWideShort),
              const SizedBox(width: 8),
              const Text("Registros por página: "),
              DropdownButton<int>(
                value: registrosPorPagina,
                items: [5, 10, 20].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text("$value"),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      registrosPorPagina = newValue;
                      paginaAtual = 1;
                    });
                  }
                },
              ),
            ],
          ),
          Row(
            children: [
              const Text("Ordenação: "),
              const SizedBox(width: 8),
              Text(isOrdenacaoDecrescente ? "Decrescente" : "Crescente"),
              Switch(
                value: isOrdenacaoDecrescente,
                onChanged: (bool value) {
                  setState(() {
                    isOrdenacaoDecrescente = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget exibirCardPedido(Pedido pedido, Map<String, String> infoPessoa) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(FontAwesomeIcons.hashtag, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Código do Pedido: ${GeradorCodigoPedido.codigoReduzido(pedido.id!)}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: StatusPedido.values
                      .firstWhere((status) => status.nome == pedido.status)
                      .cor,
                  size: 10,
                ),
                const SizedBox(width: 5),
                Text("Status: ${pedido.status}"),
                const Spacer(),
                Text(pedido.isEncomenda ? 'Encomenda' : 'Pedido'),
              ],
            ),
            const SizedBox(height: 8),
            const Text("Valor a ser pago:",
                style: TextStyle(color: Colors.black54)),
            Text(
              FormatadorMoedaReal.formatarValorReal(pedido.valorTotal),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => detalharPedido(pedido, infoPessoa),
                    child: const Text("Detalhes",
                        style: TextStyle(color: Colors.purple)),
                  ),
                  if (pedido.status == StatusPedido.PENDENTE.nome)
                    TextButton(
                      onPressed: () => cancelarPedido(pedido),
                      child: const Text("Cancelar pedido",
                          style: TextStyle(color: Colors.red)),
                    ),
                  if (widget.isHistoricoEmpresa) ...[
                    if (pedido.status == StatusPedido.PENDENTE.nome)
                      TextButton(
                        onPressed: () {
                          aceitarPedido(pedido);
                        },
                        child: const Text("Aceitar Pedido",
                            style: TextStyle(color: Colors.blue)),
                      ),
                    if (pedido.status == StatusPedido.EM_ANDAMENTO.nome)
                      TextButton(
                        onPressed: () {
                          finalizarPedido(pedido);
                        },
                        child: const Text("Finalizar Pedido",
                            style: TextStyle(color: Colors.green)),
                      ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Pedido> aplicarFiltros(AsyncValue<List<Pedido>> pedidosAsync) {
    pedidosAsync.whenData((pedidos) {
      listaPedidosFinal = statusSelecionado == "Todos"
          ? pedidos
          : pedidos
              .where((pedido) => pedido.status == statusSelecionado)
              .toList();
      listaPedidosFinal.sort((a, b) => b.dataPedido.compareTo(a.dataPedido));
    });

    listaPedidosFinal.sort((a, b) {
      int cmp = a.dataPedido.toDate().compareTo(b.dataPedido.toDate());
      return isOrdenacaoDecrescente ? -cmp : cmp;
    });

    int totalRegistros = listaPedidosFinal.length;
    int indiceInicial = (paginaAtual - 1) * registrosPorPagina;
    int indiceFinal = min(indiceInicial + registrosPorPagina, totalRegistros);
    return listaPedidosFinal.sublist(indiceInicial, indiceFinal);
  }

  Widget exibirPaginacao() {
    int totalPages = (listaPedidosFinal.length / registrosPorPagina).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed:
                paginaAtual > 1 ? () => setState(() => paginaAtual--) : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Text("Página $paginaAtual de $totalPages"),
          IconButton(
            onPressed: paginaAtual < totalPages
                ? () => setState(() => paginaAtual++)
                : null,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  Widget exibirDadosItemPedido(ItemPedido item, Pedido pedido) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ref
          .read(historicoPedidoControllerProvider(widget.isHistoricoEmpresa)
              .notifier)
          .obterDadosItemPedido(item.produtoId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Erro: ${snapshot.error}");
        } else if (snapshot.hasData) {
          final dados = snapshot.data!;
          return Wrap(
            children: [
              Text("${dados['descricao']}"),
              const SizedBox(width: 8),
              Text(FormatadorMoedaReal.formatarValorReal(dados['preco'])),
              const SizedBox(width: 8),
              Text("(x${item.quantidade})"),
            ],
          );
        } else {
          return const Text("Dados não disponíveis");
        }
      },
    );
  }

  Widget exibirPainelVendedor(AsyncValue<List<Pedido>> pedidosAsync) {
    List<Pedido> vendasConcluidas = [];
    pedidosAsync.whenData((pedidos) {
      vendasConcluidas = pedidos
          .where((pedido) => pedido.status == StatusPedido.FINALIZADO.nome)
          .toList();
    });
    double totalVendas =
        vendasConcluidas.fold(0.0, (sum, pedido) => sum + pedido.valorTotal);
    int quantidadeVendas = vendasConcluidas.length;
    double ticketMedio =
        quantidadeVendas > 0 ? totalVendas / quantidadeVendas : 0.0;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Resumo de Vendas Concluídas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  exibirDadosResumoVendas(
                      "Total de Vendas", "$quantidadeVendas"),
                  exibirDadosResumoVendas("Valor Total",
                      FormatadorMoedaReal.formatarValorReal(totalVendas)),
                  exibirDadosResumoVendas("Ticket Médio",
                      FormatadorMoedaReal.formatarValorReal(ticketMedio)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget exibirDadosResumoVendas(String titulo, String valor) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(valor,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void detalharPedido(Pedido pedido, Map<String, String> infoPessoa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text("Detalhes do Pedido")),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.isHistoricoEmpresa
                  ? "Cliente: ${infoPessoa['nome']} - ${infoPessoa['telefone']}"
                  : "Empresa: ${infoPessoa['nome']} - ${infoPessoa['telefone']}"),
              const SizedBox(height: 8),
              Text("Local de Entrega Selecionado: ${pedido.localRetirada}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Observação do pedido: ${pedido.observacao}"),
              const SizedBox(height: 8),
              const Text("Itens do pedido:"),
              for (var item in pedido.itensPedido)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: exibirDadosItemPedido(item, pedido),
                ),
              const SizedBox(height: 8),
              if (pedido.motivoCancelamento != null &&
                  pedido.motivoCancelamento!.isNotEmpty)
                Text("Motivo do cancelamento: ${pedido.motivoCancelamento}"),
              const SizedBox(height: 8),
              Text(
                  "Última alteração: ${DateFormat('dd/MM/yyyy HH:mm').format(pedido.dataUltimaAlteracao.toDate())}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  void aceitarPedido(Pedido pedido) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            const Icon(FontAwesomeIcons.check, color: Colors.green, size: 40),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Confirmar Pedido",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Deseja confirmar o pedido? Uma notificação será enviada ao cliente.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Não"),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(historicoPedidoControllerProvider(
                          widget.isHistoricoEmpresa)
                      .notifier)
                  .atualizarPedido(pedido.id!, StatusPedido.EM_ANDAMENTO, null);

              NotificacaoUtils.enviarNotificacaoPedido(
                  pedido.usuarioClienteId, ref, StatusPedido.EM_ANDAMENTO);

              if (!context.mounted) return;

              Navigator.of(context).pop();
              SnackBarUtil.showSnackbar(
                  mensagem: "Pedido confirmado com sucesso!",
                  context: context,
                  erro: false);
            },
            child: const Text("Sim"),
          ),
        ],
      ),
    );
  }

  void cancelarPedido(Pedido pedido) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(FontAwesomeIcons.circleXmark,
            color: Colors.red, size: 40),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Cancelar Pedido",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Você tem certeza que deseja cancelar este pedido?",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _motivoCancelamentoController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(FontAwesomeIcons.broom),
                  onPressed: () => _motivoCancelamentoController.clear(),
                ),
                labelText: "Digite o motivo:",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                pedido.motivoCancelamento = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Campo obrigatório";
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Não"),
          ),
          TextButton(
            onPressed: () async {
              if (_motivoCancelamentoController.text.isNotEmpty) {
                await ref
                    .read(historicoPedidoControllerProvider(
                            widget.isHistoricoEmpresa)
                        .notifier)
                    .atualizarPedido(pedido.id!, StatusPedido.CANCELADO,
                        _motivoCancelamentoController.text);

                NotificacaoUtils.enviarNotificacaoPedido(
                    pedido.usuarioClienteId, ref, StatusPedido.CANCELADO);

                if (!context.mounted) return;

                Navigator.of(context).pop();
                SnackBarUtil.showSnackbar(
                    mensagem: "Pedido cancelado com sucesso!",
                    context: context,
                    erro: false);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Motivo de cancelamento obrigatório")),
                );
              }
            },
            child: const Text("Sim"),
          ),
        ],
      ),
    );
  }

  void finalizarPedido(Pedido pedido) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(FontAwesomeIcons.checkDouble,
            color: Colors.green, size: 40),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Finalizar Pedido",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Deseja finalizar o pedido? Ele será marcado como concluído e constará no saldo de vendas.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Não"),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(historicoPedidoControllerProvider(
                          widget.isHistoricoEmpresa)
                      .notifier)
                  .atualizarPedido(pedido.id!, StatusPedido.FINALIZADO, null);

              NotificacaoUtils.enviarNotificacaoPedido(
                  pedido.usuarioClienteId, ref, StatusPedido.FINALIZADO);

              if (!context.mounted) return;

              Navigator.of(context).pop();
              SnackBarUtil.showSnackbar(
                  mensagem: "Pedido finalizado com sucesso!",
                  context: context,
                  erro: false);
            },
            child: const Text("Sim"),
          ),
        ],
      ),
    );
  }
}
