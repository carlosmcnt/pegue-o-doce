import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/empresa/services/empresa_service.dart';
import 'package:pegue_o_doce/usuario/services/usuario_service.dart';

part 'empresa_edit_controller.g.dart';

@riverpod
class EmpresaEditController extends _$EmpresaEditController {
  @override
  Future<Empresa> build() async {
    state = const AsyncValue.loading();
    final usuarioLogado =
        await ref.read(usuarioServiceProvider).obterUsuarioLogado();
    final empresa = await ref
        .read(empresaServiceProvider)
        .obterEmpresaPorUsuarioId(usuarioLogado.id!);
    state = AsyncValue.data(empresa!);
    return empresa;
  }

  Future<void> inserirOuAtualizarEmpresa(Empresa empresa) async {
    final empresaService = ref.read(empresaServiceProvider);
    state = const AsyncValue.loading();
    if (empresa.id == null) {
      await empresaService.criarEmpresa(empresa);
    } else {
      await empresaService.atualizarEmpresa(empresa);
    }
    state = await AsyncValue.guard(() async {
      final result = await empresaService.obterEmpresaPorId(empresa.id!);
      if (result == null) {
        throw Exception('Empresa not found');
      }
      return result;
    });
  }
}
