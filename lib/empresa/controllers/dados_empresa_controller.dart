import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/empresa/services/empresa_service.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/produto/services/produto_service.dart';
import 'package:pegue_o_doce/usuario/models/usuario_empresa.dart';
import 'package:pegue_o_doce/usuario/services/usuario_empresa_service.dart';
import 'package:pegue_o_doce/usuario/services/usuario_service.dart';

part 'dados_empresa_controller.g.dart';

@riverpod
class DadosEmpresaController extends _$DadosEmpresaController {
  @override
  Future<List<Produto>> build() async {
    state = const AsyncValue.loading();
    try {
      final usuarioId =
          await ref.read(usuarioServiceProvider).obterIdUsuarioLogado();
      final empresa = await ref
          .read(empresaServiceProvider)
          .obterEmpresaPorUsuarioId(usuarioId);

      if (empresa != null) {
        final produtos = await ref
            .read(produtoServiceProvider)
            .getProdutosPorEmpresa(empresa.id!);
        state = AsyncValue.data(produtos);
        return produtos;
      } else {
        state = const AsyncValue.data([]);
        return [];
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return [];
    }
  }

  Future<void> adicionarEmpresaFavorita(UsuarioEmpresa usuarioEmpresa) async {
    await ref.read(usuarioEmpresaServiceProvider).adicionar(usuarioEmpresa);
  }

  Future<String> obterIdUsuarioLogado() async {
    String? id = await ref.read(usuarioServiceProvider).obterIdUsuarioLogado();
    return id;
  }

  Future<String> obterTelefoneContatoPorIdEmpresa(String idUsuario) async {
    final usuario =
        await ref.read(usuarioServiceProvider).obterUsuarioPorId(idUsuario);
    return usuario.telefone;
  }

  Future<void> salvarTokenFCM(String usuarioId) async {
    await ref.read(usuarioServiceProvider).salvarTokenFCM(usuarioId);
  }
}
