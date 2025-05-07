import 'package:pegue_o_doce/empresa/services/empresa_service.dart';
import 'package:pegue_o_doce/pedido/models/status_pedido.dart';
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

  Future<void> atualizarPedido(
      String pedidoId, StatusPedido status, String? motivoCancelamento) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(pedidoServiceProvider)
          .atualizarPedido(pedidoId, status, motivoCancelamento);
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

  Future<Map<String, String>> obterNomeClienteOuEmpresa(
      String pedidoId, bool isHistoricoEmpresa) async {
    if (isHistoricoEmpresa) {
      final pedido =
          await ref.read(pedidoServiceProvider).getPedidoPorId(pedidoId);
      String idCliente = pedido?.usuarioClienteId ?? '';
      final cliente =
          await ref.read(usuarioServiceProvider).obterUsuarioPorId(idCliente);
      return {
        'nome': cliente.nomeCompleto,
        'telefone': cliente.telefone,
      };
    } else {
      final pedido =
          await ref.read(pedidoServiceProvider).getPedidoPorId(pedidoId);
      String idVendedor = pedido?.usuarioVendedorId ?? '';
      final vendedor = await ref
          .read(empresaServiceProvider)
          .obterEmpresaPorUsuarioId(idVendedor);
      final usuarioVendedor =
          await ref.read(usuarioServiceProvider).obterUsuarioPorId(idVendedor);
      return {
        'nome': vendedor!.nomeFantasia,
        'telefone': usuarioVendedor.telefone,
      };
    }
  }
}
