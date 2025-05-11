import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WidgetUtils {
  static void showSnackbar(
      {required String mensagem,
      required BuildContext context,
      required bool erro}) {
    SnackBar snackbar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(mensagem),
      backgroundColor: erro ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  static void showLoadingDialog(BuildContext context, {String? mensagem}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(mensagem ?? 'Carregando...'),
            ],
          ),
        );
      },
    );
  }

  static SizedBox textoInformacao(String texto) {
    return SizedBox(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              const WidgetSpan(
                  child: Icon(FontAwesomeIcons.circleInfo, color: Colors.blue)),
              const WidgetSpan(child: SizedBox(width: 10)),
              TextSpan(
                text: texto,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
