import 'package:flutter/material.dart';
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
  final ValueNotifier<double> valorNotifier;
  static bool _bloquearFormatacao = false;

  final NumberFormat _formatter =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  FormatadorMoedaReal({required this.valorNotifier});

  static void bloquearFormatacaoTemporariamente(void Function() atualizar) {
    _bloquearFormatacao = true;
    atualizar();
    _bloquearFormatacao = false;
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (_bloquearFormatacao) return newValue;

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      valorNotifier.value = 0.0;
      return newValue.copyWith(text: '');
    }

    final value = double.parse(digitsOnly) / 100;
    valorNotifier.value = value;
    final newText = _formatter.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
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
