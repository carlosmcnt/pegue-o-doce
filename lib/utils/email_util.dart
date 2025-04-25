import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pegue_o_doce/pedido/controllers/encomenda_controller.dart';
import 'package:pegue_o_doce/pedido/models/item_pedido.dart';
import 'package:pegue_o_doce/pedido/models/pedido.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/usuario/models/usuario.dart';
import 'package:pegue_o_doce/usuario/views/menu_principal_page.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:http/http.dart' as http;
import 'package:pegue_o_doce/utils/gerador_codigo_pedido.dart';

class EmailUtil {
  static Future<void> enviarEmailEncomenda(
    BuildContext context,
    String localEntrega,
    Pedido pedido,
    List<Produto> produtos,
    WidgetRef ref,
  ) async {
    final Usuario usuarioVendedor = await ref
        .read(encomendaControllerProvider.notifier)
        .obterUsuarioPorId(pedido.usuarioVendedorId);

    bool isEncomenda = pedido.isEncomenda;

    String tipo = isEncomenda ? 'Encomenda' : 'Pedido';

    final List<ItemPedido> itensPedido = pedido.itensPedido;

    final detalhesItens = itensPedido.map((item) {
      final produto = produtos.firstWhere((p) => p.id == item.produtoId);
      return '${produto.tipo} - ${produto.sabor} (Quantidade: ${item.quantidade})';
    }).join('\n');

    final emailBody = '''
      Local de Entrega: $localEntrega

      Itens do Pedido:
      $detalhesItens

      Total: ${FormatadorMoedaReal.formatarValorReal(pedido.valorTotal)}
    ''';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': const String.fromEnvironment('EMAILJS_SERVICE_ID'),
        'template_id': const String.fromEnvironment('EMAILJS_TEMPLATE_ID'),
        'user_id': const String.fromEnvironment('EMAILJS_USER_ID'),
        'template_params': {
          'to_email': usuarioVendedor.email,
          'codigo_pedido':
              GeradorCodigoPedido.codigoReduzido(pedido.usuarioClienteId),
          'tipo': tipo,
          'mensagem': emailBody,
        },
      }),
    );

    if (response.statusCode == 200) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email enviado com sucesso!'),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MenuPrincipalPage()),
        (route) => false,
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao enviar email.'),
        ),
      );
      throw Exception('Erro ao enviar email: ${response.body}');
    }
  }
}
