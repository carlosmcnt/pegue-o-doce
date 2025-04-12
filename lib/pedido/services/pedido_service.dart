import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/pedido/models/pedido.dart';
import 'package:pegue_o_doce/pedido/repositories/pedido_repository.dart';

part 'pedido_service.g.dart';

class PedidoService {
  final PedidoRepository pedidoRepository;

  PedidoService({required this.pedidoRepository});

  Future<Pedido> inserirPedido(Pedido pedido) async {
    return await pedidoRepository.inserirPedido(pedido);
  }

  Future<Pedido?> getPedidoPorId(String id) async {
    return await pedidoRepository.getPedidoPorId(id);
  }

  Stream<List<Pedido>> getPedidos() {
    return pedidoRepository.getPedidos();
  }

  Stream<List<Pedido>> getPedidosPorStatus(String status) {
    return pedidoRepository.getPedidosPorStatus(status);
  }

  Future<List<Pedido>> getPedidosPorCliente(String usuarioId) async {
    return await pedidoRepository.getPedidosPorCliente(usuarioId);
  }

  Future<List<Pedido>> getPedidosPorVendedor(String usuarioId) async {
    return await pedidoRepository.getPedidosPorVendedor(usuarioId);
  }

  Future<void> cancelarPedido(
      String pedidoId, String motivoCancelamento) async {
    await pedidoRepository.cancelarPedido(pedidoId, motivoCancelamento);
  }
}

@Riverpod(keepAlive: true)
PedidoService pedidoService(Ref ref) {
  final repository = ref.watch(pedidoRepositoryProvider);
  return PedidoService(pedidoRepository: repository);
}
