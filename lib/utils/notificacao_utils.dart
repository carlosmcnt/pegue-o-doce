// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pegue_o_doce/pedido/models/status_pedido.dart';
import 'package:pegue_o_doce/usuario/models/usuario.dart';
import 'package:pegue_o_doce/usuario/services/usuario_service.dart';

class NotificacaoUtils {
  static String TITULO_NOVO_PEDIDO = 'Novo Pedido';
  static String TITULO_PEDIDO_ACEITO = 'Pedido Aceito';
  static String TITULO_PEDIDO_FINALIZADO = 'Pedido Finalizado';
  static String TITULO_PEDIDO_CANCELADO = 'Pedido Cancelado';
  static String MENSAGEM_NOVO_PEDIDO = '✅ Você tem um novo pedido, abra o app!';
  static String MENSAGEM_PEDIDO_ACEITO =
      '✅ Seu pedido foi aceito! Para mais informações, entre em contato com o vendedor.';
  static String MENSAGEM_PEDIDO_FINALIZADO =
      '✅ Seu pedido foi finalizado! Caso tenha alguma dúvida, entre em contato com o vendedor.';
  static String MENSAGEM_PEDIDO_CANCELADO =
      '❌ Seu pedido foi cancelado! Caso tenha alguma dúvida, entre em contato com o vendedor.';

  static Future<void> enviarNotificacaoPush({required String token}) async {
    String appId = dotenv.env['ONESIGNAL_APP_ID']!;
    String restApiKey = dotenv.env['ONESIGNAL_REST_API_KEY']!;

    var url = Uri.parse('https://onesignal.com/api/v1/notifications');

    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Basic $restApiKey',
    };

    var payload = {
      'app_id': appId,
      'include_player_ids': [token],
      'headings': {'en': TITULO_NOVO_PEDIDO},
      'contents': {'en': MENSAGEM_NOVO_PEDIDO},
    };

    var response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao enviar notificação: ${response.statusCode}');
    }
  }

  static Future<void> enviarNotificacaoPedido(
      String usuarioClienteId, WidgetRef ref, StatusPedido status) async {
    String appId = dotenv.env['ONESIGNAL_APP_ID']!;
    String restApiKey = dotenv.env['ONESIGNAL_REST_API_KEY']!;

    var url = Uri.parse('https://onesignal.com/api/v1/notifications');

    Usuario usuario = await ref
        .read(usuarioServiceProvider)
        .obterUsuarioPorId(usuarioClienteId);

    String tituloNotificacao;
    String mensagemNotificacao;

    switch (status) {
      case StatusPedido.EM_ANDAMENTO:
        tituloNotificacao = TITULO_PEDIDO_ACEITO;
        mensagemNotificacao = MENSAGEM_PEDIDO_ACEITO;
        break;
      case StatusPedido.FINALIZADO:
        tituloNotificacao = TITULO_PEDIDO_FINALIZADO;
        mensagemNotificacao = MENSAGEM_PEDIDO_FINALIZADO;
        break;
      case StatusPedido.CANCELADO:
        tituloNotificacao = TITULO_PEDIDO_CANCELADO;
        mensagemNotificacao = MENSAGEM_PEDIDO_CANCELADO;
        break;
      default:
        throw Exception('Status de pedido inválido');
    }

    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Basic $restApiKey',
    };

    var payload = {
      'app_id': appId,
      'include_player_ids': [usuario.token],
      'headings': {'en': tituloNotificacao},
      'contents': {
        'en': mensagemNotificacao,
      },
    };

    var response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao enviar notificação: ${response.statusCode}');
    }
  }
}
