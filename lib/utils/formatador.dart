import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NormalizadorMoeda {
  static double normalizar(String value) {
    String normalized = value
        .replaceAll(
            NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
            ).currencySymbol,
            '')
        .trim();
    normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }
}

class FormatadorMoedaReal extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double valor = double.parse(newValue.text);
    final formatador = NumberFormat("#,##0.00", "pt_BR");
    String valorFormatado = formatador.format(valor / 100);

    return newValue.copyWith(
        text: valorFormatado,
        selection: TextSelection.collapsed(offset: valorFormatado.length));
  }

  static String formatarValorReal(double valor) {
    return "R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(valor)}";
  }
}

class FormatadorLetrasMaiusculas extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
