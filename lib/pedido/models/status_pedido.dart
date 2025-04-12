import 'package:flutter/material.dart';

// ignore: constant_identifier_names
enum StatusPedido { TODOS, PENDENTE, CANCELADO, ENTREGUE, FINALIZADO }

extension StatusPedidoExtension on StatusPedido {
  String get nome {
    switch (this) {
      case StatusPedido.PENDENTE:
        return 'Pendente';
      case StatusPedido.CANCELADO:
        return 'Cancelado';
      case StatusPedido.ENTREGUE:
        return 'Entregue';
      case StatusPedido.FINALIZADO:
        return 'Finalizado';
      default:
        return 'Todos';
    }
  }

  Color get cor {
    switch (this) {
      case StatusPedido.PENDENTE:
        return Colors.orange;
      case StatusPedido.CANCELADO:
        return Colors.red;
      case StatusPedido.ENTREGUE:
        return Colors.blue;
      case StatusPedido.FINALIZADO:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
