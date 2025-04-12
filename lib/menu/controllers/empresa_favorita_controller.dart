import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/empresa/services/empresa_service.dart';
import 'package:pegue_o_doce/usuario/repositories/usuario_empresa_repository.dart';
import 'package:pegue_o_doce/usuario/services/usuario_service.dart';

part 'empresa_favorita_controller.g.dart';

@riverpod
class EmpresaFavoritaController extends _$EmpresaFavoritaController {
  @override
  Future<List<Empresa>> build() async {
    state = const AsyncValue.loading();
    final empresas = await ref.read(empresaServiceProvider).getEmpresas();
    state = AsyncValue.data(empresas);
    return empresas;
  }

  Future<List<Empresa>> obterListaEmpresasFavoritasPorUsuarioLogado() async {
    final usuario = await ref.read(usuarioServiceProvider).obterUsuarioLogado();
    final empresasFavoritas = <Empresa>[];
    final listaUsuarioEmpresaFavoritado = await ref
        .read(usuarioEmpresaRepositoryProvider)
        .obterEmpresasFavoritasPorUsuario(usuario.id!);
    for (final usuarioEmpresa in listaUsuarioEmpresaFavoritado) {
      final empresa = await ref
          .read(empresaServiceProvider)
          .obterEmpresaPorId(usuarioEmpresa.empresaId);
      empresasFavoritas.add(empresa!);
    }
    return empresasFavoritas;
  }

  Future<void> removerEmpresaFavorita(String empresaId) async {
    state = const AsyncValue.loading();
    final usuario = await ref.read(usuarioServiceProvider).obterUsuarioLogado();
    await ref
        .read(usuarioEmpresaRepositoryProvider)
        .removerEmpresaFavorita(usuario.id!, empresaId);
  }
}
