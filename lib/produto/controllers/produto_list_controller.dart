import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/categoria/models/categoria.dart';
import 'package:pegue_o_doce/categoria/services/categoria_service.dart';
import 'package:pegue_o_doce/empresa/services/empresa_service.dart';
import 'package:pegue_o_doce/usuario/services/usuario_service.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/produto/services/produto_service.dart';

part 'produto_list_controller.g.dart';

@riverpod
class ProdutoListController extends _$ProdutoListController {
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

  Future<void> verificarEstado() async {
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
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> inserirOuAtualizarProduto(Produto produto) async {
    final produtoService = ref.read(produtoServiceProvider);
    state = const AsyncValue.loading();
    if (produto.id == null) {
      await produtoService.criarProduto(produto);
    } else {
      await produtoService.atualizarProduto(produto);
    }

    final idUsuarioAtivo =
        await ref.read(usuarioServiceProvider).obterIdUsuarioLogado();
    final empresa = await ref
        .read(empresaServiceProvider)
        .obterEmpresaPorUsuarioId(idUsuarioAtivo);
    state = await AsyncValue.guard(() async {
      return ref
          .read(produtoServiceProvider)
          .getProdutosPorEmpresa(empresa!.id!);
    });
  }

  Future<List<Categoria>> buscarCategorias() async {
    final categoriaService = ref.read(categoriaServiceProvider);
    return categoriaService.getCategoriasAtivas();
  }

  Future<Categoria> buscarCategoriaPorProdutoId(String idProduto) async {
    final categoriaService = ref.read(categoriaServiceProvider);
    return categoriaService.getCategoriaPorIdProduto(idProduto);
  }

  Future<void> deletarProduto(Produto produto) async {
    final produtoService = ref.read(produtoServiceProvider);
    state = const AsyncValue.loading();
    await produtoService.deletarProduto(produto.id!);
    final idUsuarioAtivo =
        await ref.read(usuarioServiceProvider).obterIdUsuarioLogado();
    final empresa = await ref
        .read(empresaServiceProvider)
        .obterEmpresaPorUsuarioId(idUsuarioAtivo);
    state = await AsyncValue.guard(() async {
      return ref
          .read(produtoServiceProvider)
          .getProdutosPorEmpresa(empresa!.id!);
    });
  }
}
