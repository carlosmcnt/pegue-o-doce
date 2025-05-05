// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/usuario/models/usuario.dart';
import 'package:pegue_o_doce/usuario/repositories/usuario_repository.dart';
import 'package:pegue_o_doce/utils/snackbar_util.dart';

part 'usuario_service.g.dart';

class UsuarioService {
  final UsuarioRepository usuarioRepository;

  UsuarioService({required this.usuarioRepository});

  Future<dynamic> login(
      String email, String senha, BuildContext context) async {
    final resultado =
        await usuarioRepository.entrar(email: email, senha: senha);
    if (resultado == true) {
      SnackBarUtil.showSnackbar(
        mensagem: 'Login realizado com sucesso!',
        context: context,
        erro: false,
      );
      return true;
    } else {
      SnackBarUtil.showSnackbar(
        mensagem: resultado,
        context: context,
        erro: true,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await usuarioRepository.sair();
  }

  Future<dynamic> redefinirSenha(String email, BuildContext context) async {
    final resultado = await usuarioRepository.redefinirSenha(email: email);
    if (resultado == true) {
      SnackBarUtil.showSnackbar(
        mensagem: 'Redefinição de senha enviada para o e-mail!',
        context: context,
        erro: false,
      );
    } else {
      SnackBarUtil.showSnackbar(
        mensagem: resultado,
        context: context,
        erro: true,
      );
    }
  }

  Future<dynamic> registrar(
      {required String nome,
      required String email,
      required String cpf,
      required String senha,
      required String telefone,
      String? token,
      required BuildContext context}) async {
    final resultado = await usuarioRepository.registrar(
      nomeCompleto: nome,
      email: email,
      cpf: cpf,
      senha: senha,
      telefone: telefone,
      token: token ?? '',
    );
    if (resultado == true) {
      SnackBarUtil.showSnackbar(
        mensagem: 'Cadastro realizado com sucesso!',
        context: context,
        erro: false,
      );
      return true;
    } else {
      SnackBarUtil.showSnackbar(
        mensagem: resultado,
        context: context,
        erro: true,
      );
      return false;
    }
  }

  Future<String> obterIdUsuarioLogado() async {
    return await usuarioRepository.obterIdUsuarioLogado();
  }

  Future<Usuario> obterUsuarioLogado() async {
    return await usuarioRepository.obterUsuarioAtual();
  }

  Future<void> atualizarUsuario(Usuario usuario) async {
    await usuarioRepository.atualizarUsuario(usuario);
  }

  Future<Usuario> obterUsuarioPorId(String usuarioId) async {
    return await usuarioRepository.obterUsuarioPorId(usuarioId);
  }
}

@Riverpod(keepAlive: true)
UsuarioService usuarioService(Ref ref) {
  final repository = ref.watch(usuarioRepositoryProvider);
  return UsuarioService(usuarioRepository: repository);
}
