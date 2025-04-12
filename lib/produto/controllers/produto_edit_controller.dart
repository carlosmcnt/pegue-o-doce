import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/produto/services/produto_service.dart';

part 'produto_edit_controller.g.dart';

@riverpod
class ProdutoEditController extends _$ProdutoEditController {
  @override
  Future<Produto> build(Produto produto) async {
    return produto;
  }

  Future<void> inserirOuAtualizar() async {
    Produto produto = state.value!;
    final produtoService = ref.read(produtoServiceProvider);
    state = const AsyncValue.loading();
    if (produto.id == null) {
      produto = await produtoService.criarProduto(produto);
    } else {
      await produtoService.atualizarProduto(produto);
    }
    state = await AsyncValue.guard(() => Future.value(produto));
  }
}
