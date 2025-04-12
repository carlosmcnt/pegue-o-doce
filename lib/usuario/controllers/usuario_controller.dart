import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/usuario/models/usuario.dart';
import 'package:pegue_o_doce/usuario/services/usuario_service.dart';

part 'usuario_controller.g.dart';

@riverpod
class UsuarioController extends _$UsuarioController {
  @override
  Future<Usuario> build() async {
    final usuario = await ref.read(usuarioServiceProvider).obterUsuarioLogado();
    return usuario;
  }

  Future<bool> login(String email, String senha, BuildContext context) async {
    return await ref.read(usuarioServiceProvider).login(email, senha, context);
  }

  Future<bool> cadastrar(String nome, String email, String senha, String cpf,
      String telefone, BuildContext context) async {
    return await ref.read(usuarioServiceProvider).registrar(
        nome: nome,
        email: email,
        senha: senha,
        cpf: cpf,
        telefone: telefone,
        context: context);
  }

  Future<void> logout() async {
    await ref.read(usuarioServiceProvider).logout();
  }
}
