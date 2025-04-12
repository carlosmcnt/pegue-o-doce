import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/usuario/models/usuario_empresa.dart';
import 'package:pegue_o_doce/usuario/repositories/usuario_empresa_repository.dart';

part 'usuario_empresa_service.g.dart';

class UsuarioEmpresaService {
  final UsuarioEmpresaRepository usuarioEmpresaRepository;

  UsuarioEmpresaService({required this.usuarioEmpresaRepository});

  Future<void> adicionar(UsuarioEmpresa usuarioEmpresa) async {
    await usuarioEmpresaRepository.adicionar(usuarioEmpresa);
  }

  Future<void> removerEmpresaFavoritaPagePage(
      String idUsuario, String idEmpresa) async {
    await usuarioEmpresaRepository.removerEmpresaFavorita(idUsuario, idEmpresa);
  }

  Future<bool> existeUsuarioEmpresa(UsuarioEmpresa usuarioEmpresa) async {
    return await usuarioEmpresaRepository.existeUsuarioEmpresa(usuarioEmpresa);
  }

  Future<List<UsuarioEmpresa>> obterEmpresasFavoritasPorUsuario(
      String usuarioId) async {
    return await usuarioEmpresaRepository
        .obterEmpresasFavoritasPorUsuario(usuarioId);
  }
}

@Riverpod(keepAlive: true)
UsuarioEmpresaService usuarioEmpresaService(Ref ref) {
  final repository = ref.watch(usuarioEmpresaRepositoryProvider);
  return UsuarioEmpresaService(usuarioEmpresaRepository: repository);
}
