import 'package:br_validators/br_validators.dart';
import 'package:flutter/material.dart';

class Validador {
  static bool emailValido(String email) {
    String padrao =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(padrao);
    return (!regex.hasMatch(email)) ? false : true;
  }

  static bool validarSenhaForte(String senha) {
    String padrao =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp regex = RegExp(padrao);
    return (!regex.hasMatch(senha)) ? false : true;
  }

  static String aplicarMascaraCPF(String cpf) {
    String padrao = r'(\d{3})(\d{3})(\d{3})(\d{2})';
    RegExp regex = RegExp(padrao);
    return cpf.replaceAllMapped(
        regex, (Match m) => '${m[1]}.${m[2]}.${m[3]}-${m[4]}');
  }

  static String aplicarMascaraCNPJ(String cnpj) {
    String padrao = r'(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})';
    RegExp regex = RegExp(padrao);
    return cnpj.replaceAllMapped(
        regex, (Match m) => '${m[1]}.${m[2]}.${m[3]}/${m[4]}-${m[5]}');
  }

  static String aplicarMascaraTelefoneSemDDD(String telefone) {
    String padrao = r'(\d{2})(\d{5})(\d{4})';
    RegExp regex = RegExp(padrao);
    return telefone.replaceAllMapped(
        regex, (Match m) => '(${m[1]}) ${m[2]}-${m[3]}');
  }

  static bool validarChavePixSelecionada(String valorChave, String tipo) {
    switch (tipo) {
      case 'E-mail':
        return emailValido(valorChave);
      case 'Chave Aleatória':
        return valorChave.length == 32;
      case 'CPF':
        return BRValidators.validateCPF(aplicarMascaraCPF(valorChave));
      case 'CNPJ':
        return BRValidators.validateCNPJ(aplicarMascaraCNPJ(valorChave));
      case 'Telefone':
        return BRValidators.validateMobileNumber(
            aplicarMascaraTelefoneSemDDD(valorChave));
      default:
        return false;
    }
  }

  List<DropdownMenuEntry<String>> listaTiposChavesPix() {
    return [
      const DropdownMenuEntry(
        value: '',
        label: '',
      ),
      const DropdownMenuEntry(
        value: 'CPF',
        label: 'CPF',
      ),
      const DropdownMenuEntry(
        value: 'CNPJ',
        label: 'CNPJ',
      ),
      const DropdownMenuEntry(
        value: 'E-mail',
        label: 'E-mail',
      ),
      const DropdownMenuEntry(
        value: 'Telefone',
        label: 'Telefone',
      ),
      const DropdownMenuEntry(
        value: 'Chave Aleatória',
        label: 'Chave Aleatória',
      ),
    ];
  }
}
