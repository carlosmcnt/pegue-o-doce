import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/usuario/models/usuario.dart';
import 'package:pegue_o_doce/usuario/services/usuario_service.dart';

part 'dados_usuario_controller.g.dart';

@riverpod
class DadosUsuarioController extends _$DadosUsuarioController {
  @override
  Future<Usuario> build() async {
    state = const AsyncValue.loading();
    try {
      final usuario =
          await ref.read(usuarioServiceProvider).obterUsuarioLogado();
      state = AsyncValue.data(usuario);
      return usuario;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> verificarEstado() async {
    state = const AsyncValue.loading();
    try {
      final usuario =
          await ref.read(usuarioServiceProvider).obterUsuarioLogado();
      state = AsyncValue.data(usuario);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> atualizarUsuario(Usuario usuario) async {
    final usuarioService = ref.read(usuarioServiceProvider);
    state = const AsyncValue.loading();
    await usuarioService.atualizarUsuario(usuario);
    state = await AsyncValue.guard(() async {
      return ref.read(usuarioServiceProvider).obterUsuarioLogado();
    });
  }
}
