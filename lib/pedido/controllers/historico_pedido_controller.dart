import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/pedido/models/pedido.dart';
import 'package:pegue_o_doce/pedido/services/pedido_service.dart';
import 'package:pegue_o_doce/produto/services/produto_service.dart';
import 'package:pegue_o_doce/usuario/services/usuario_service.dart';

part 'historico_pedido_controller.g.dart';

@riverpod
class HistoricoPedidoController extends _$HistoricoPedidoController {
  @override
  Future<List<Pedido>> build(bool isHistoricoEmpresa) async {
    state = const AsyncValue.loading();
    try {
      final usuarioId =
          await ref.read(usuarioServiceProvider).obterIdUsuarioLogado();
      final List<Pedido> pedidos;
      if (isHistoricoEmpresa) {
        pedidos = await ref
            .read(pedidoServiceProvider)
            .getPedidosPorVendedor(usuarioId);
      } else {
        pedidos = await ref
            .read(pedidoServiceProvider)
            .getPedidosPorCliente(usuarioId);
      }
      state = AsyncValue.data(pedidos);
      return pedidos;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return [];
    }
  }

  Future<void> cancelarPedido(String pedidoId, String motivoCancelamento,
      bool isHistoricoEmpresa) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(pedidoServiceProvider)
          .cancelarPedido(pedidoId, motivoCancelamento);
      build(true);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Map<String, dynamic>> obterDadosItemPedido(String produtoId) async {
    final produto =
        await ref.read(produtoServiceProvider).getProdutoById(produtoId);
    return {
      'descricao': '${produto?.tipo} sabor ${produto?.sabor}',
      'preco': produto?.valorUnitario,
    };
  }
}
