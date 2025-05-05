import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NotificacaoUtils {
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
      'headings': {'en': 'Pegue o Doce - Novo Pedido'},
      'contents': {'en': '✅ Você tem um novo pedido, abra o app!'},
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
