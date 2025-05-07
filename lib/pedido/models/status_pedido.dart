import 'package:flutter/material.dart';

// ignore: constant_identifier_names
enum StatusPedido { TODOS, PENDENTE, CANCELADO, EM_ANDAMENTO, FINALIZADO }

extension StatusPedidoExtension on StatusPedido {
  String get nome {
    switch (this) {
      case StatusPedido.PENDENTE:
        return 'Pendente';
      case StatusPedido.CANCELADO:
        return 'Cancelado';
      case StatusPedido.EM_ANDAMENTO:
        return 'Em Andamento';
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
      case StatusPedido.EM_ANDAMENTO:
        return Colors.blue;
      case StatusPedido.FINALIZADO:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
