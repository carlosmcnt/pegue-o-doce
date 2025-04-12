import 'dart:convert';
import 'package:crypto/crypto.dart';

class GeradorCodigoPedido {
  static String codigoReduzido(String firebaseId) {
    List<int> hash = sha256.convert(utf8.encode(firebaseId)).bytes;

    BigInt num = BigInt.zero;
    for (int i = 0; i < 6; i++) {
      num = (num << 8) | BigInt.from(hash[i]);
    }

    return toBase36(num).substring(0, 6);
  }

  static const String caracteresEmBase36 =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  static String toBase36(BigInt num) {
    StringBuffer result = StringBuffer();
    BigInt base = BigInt.from(36);
    while (num > BigInt.zero) {
      result.write(caracteresEmBase36[(num % base).toInt()]);
      num = num ~/ base;
    }
    return result.toString().padRight(6, '0').toUpperCase();
  }
}
