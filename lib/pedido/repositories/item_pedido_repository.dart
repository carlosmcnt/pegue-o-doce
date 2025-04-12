import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/firebase/firebase.dart';
import 'package:pegue_o_doce/pedido/models/item_pedido.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';

part 'item_pedido_repository.g.dart';

class ItemPedidoRepository {
  final FirebaseFirestore _firestore;

  ItemPedidoRepository(this._firestore);

  Future<ItemPedido> inserirItemPedido(ItemPedido itemPedido) async {
    final docRef =
        await _firestore.collection('itensPedidos').add(itemPedido.toMap());

    return itemPedido.copyWith(id: docRef.id);
  }

  Future<ItemPedido> obterItemPedidoPorIdPedido(String idPedido) async {
    final snapshot = await _firestore
        .collection('itensPedidos')
        .where('pedidoId', isEqualTo: idPedido)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return ItemPedido.fromDocument(snapshot.docs.first);
    }
    return ItemPedido(produtoId: '', quantidade: 0);
  }

  Future<Produto?> obterProdutoPorItemPedido(ItemPedido itemPedido) async {
    final snapshot =
        await _firestore.collection('produtos').doc(itemPedido.produtoId).get();
    if (snapshot.exists) {
      return Produto.fromDocument(snapshot);
    }
    return null;
  }

  Future<double> obterValorTotalItemPedido(ItemPedido itemPedido) async {
    final produto = await obterProdutoPorItemPedido(itemPedido);
    if (produto != null) {
      return produto.valorUnitario * itemPedido.quantidade;
    }
    return 0;
  }
}

@riverpod
ItemPedidoRepository itemPedidoRepository(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return ItemPedidoRepository(firestore);
}
