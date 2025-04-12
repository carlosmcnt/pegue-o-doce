import 'package:cloud_firestore/cloud_firestore.dart';

class ItemPedido {
  final String? id;
  final String? produtoId;
  int quantidade;

  ItemPedido({this.id, required this.produtoId, required this.quantidade});

  factory ItemPedido.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemPedido(
      id: doc.id,
      produtoId: data['produtoId'] ?? '',
      quantidade: data['quantidade'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'produtoId': produtoId,
      'quantidade': quantidade,
    };
  }

  ItemPedido copyWith({
    String? id,
    String? pedidoId,
    String? produtoId,
    int? quantidade,
  }) {
    return ItemPedido(
      id: id ?? this.id,
      produtoId: produtoId ?? this.produtoId,
      quantidade: quantidade ?? this.quantidade,
    );
  }
}
