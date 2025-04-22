import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/usuario/models/usuario.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/empresa/services/empresa_service.dart';
import 'package:pegue_o_doce/pedido/models/pedido.dart';
import 'package:pegue_o_doce/pedido/services/pedido_service.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/produto/services/produto_service.dart';
import 'package:pegue_o_doce/usuario/services/usuario_service.dart';

part 'encomenda_controller.g.dart';

@riverpod
class EncomendaController extends _$EncomendaController {
  @override
  Future<List<Produto>> build() async {
    throw UnimplementedError();
  }

  Future<List<Produto>> listarProdutos(String empresaId) async {
    final empresa =
        await ref.read(empresaServiceProvider).obterEmpresaPorId(empresaId);

    if (empresa != null) {
      final produtos = await ref
          .read(produtoServiceProvider)
          .getProdutosPorEmpresa(empresa.id!);
      state = AsyncValue.data(produtos);
      return produtos;
    }
    return [];
  }

  Future<List<String>> obterTiposDeProduto() async {
    final tipos = await ref.read(produtoServiceProvider).obterTiposDeProduto();
    return tipos;
  }

  Future<List<Produto>> obterProdutosPorTipo(String tipo) async {
    final produtos =
        await ref.read(produtoServiceProvider).obterProdutosPorTipo(tipo);
    return produtos;
  }

  Future<void> inserirPedido(Pedido pedido) async {
    final pedidoService = ref.read(pedidoServiceProvider);
    state = const AsyncValue.loading();
    if (pedido.id == null) {
      pedido = await pedidoService.inserirPedido(pedido);
    } else {
      return;
    }
    state = const AsyncValue.data([]);
  }

  Future<String> obterIdUsuarioLogado() async {
    final usuario = await ref.read(usuarioServiceProvider).obterUsuarioLogado();
    return usuario.id!;
  }

  Future<Usuario> obterUsuarioPorId(String id) async {
    final usuario =
        await ref.read(usuarioServiceProvider).obterUsuarioPorId(id);
    return usuario;
  }

  Future<List<Produto>> obterProdutosPorIds(List<String> ids) async {
    List<Produto> produtos = [];
    for (String id in ids) {
      final produto = await ref.read(produtoServiceProvider).getProdutoById(id);
      if (produto != null) {
        produtos.add(produto);
      }
    }
    return produtos;
  }

  Future<Produto> obterProdutoPorId(String id) async {
    final produto = await ref.read(produtoServiceProvider).getProdutoById(id);
    if (produto != null) {
      return produto;
    } else {
      throw Exception('Produto não encontrado');
    }
  }

  Future<Empresa> obterEmpresaPorIdProduto(String produtoId) async {
    final produto =
        await ref.read(produtoServiceProvider).getProdutoById(produtoId);
    if (produto != null) {
      final empresa = await ref
          .read(empresaServiceProvider)
          .obterEmpresaPorId(produto.empresaId);
      if (empresa != null) {
        return empresa;
      } else {
        throw Exception('Empresa não encontrada');
      }
    } else {
      throw Exception('Produto não encontrado');
    }
  }
}
