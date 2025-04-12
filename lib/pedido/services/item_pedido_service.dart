import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/pedido/models/item_pedido.dart';
import 'package:pegue_o_doce/pedido/repositories/item_pedido_repository.dart';

part 'item_pedido_service.g.dart';

class ItemPedidoService {
  final ItemPedidoRepository itemPedidoRepository;

  ItemPedidoService({required this.itemPedidoRepository});

  Future<ItemPedido> inserirItemPedido(ItemPedido itemPedido) async {
    return await itemPedidoRepository.inserirItemPedido(itemPedido);
  }

  Future<ItemPedido> obterItemPedidoPorIdPedido(String idPedido) async {
    return await itemPedidoRepository.obterItemPedidoPorIdPedido(idPedido);
  }

  Future<double> obterValorTotalItemPedido(ItemPedido itemPedido) async {
    return await itemPedidoRepository.obterValorTotalItemPedido(itemPedido);
  }
}

@Riverpod(keepAlive: true)
ItemPedidoService itemPedidoService(Ref ref) {
  final repository = ref.watch(itemPedidoRepositoryProvider);
  return ItemPedidoService(itemPedidoRepository: repository);
}
