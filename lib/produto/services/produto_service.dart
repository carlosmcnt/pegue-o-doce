import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/produto/repositories/produto_repository.dart';

part 'produto_service.g.dart';

class ProdutoService {
  final ProdutoRepository produtoRepository;

  ProdutoService({required this.produtoRepository});

  Future<Produto?> getProdutoById(String id) async {
    return await produtoRepository.getProdutoPorId(id);
  }

  Future<List<Produto>> getProdutos() async {
    return await produtoRepository.getProdutos().first;
  }

  Future<List<Produto>> getProdutosPorEmpresa(String empresaId) async {
    return await produtoRepository.getProdutosPorEmpresa(empresaId);
  }

  Future<Produto> criarProduto(Produto produto) async {
    return await produtoRepository.inserirProduto(produto);
  }

  Future<void> atualizarProduto(Produto produto) async {
    await produtoRepository.atualizarProduto(produto);
  }

  Future<void> deletarProduto(String id) async {
    await produtoRepository.deletarProduto(id);
  }

  Future<List<Produto?>> obterProdutosPorCategoria(String categoriaId) async {
    return await produtoRepository.obterProdutosPorCategoria(categoriaId);
  }

  Future<List<Produto>> obterProdutosEmpresaPorTipo(
      String tipo, String empresaId) async {
    return await produtoRepository.obterProdutosEmpresaPorTipo(tipo, empresaId);
  }

  Future<List<String>> obterTiposDeProduto() async {
    return await produtoRepository.obterTiposDeProduto();
  }

  Future<List<String>> obterTiposDeProdutoPorEmpresa(String empresaId) async {
    return await produtoRepository.obterTiposDeProdutoPorEmpresa(empresaId);
  }
}

@Riverpod(keepAlive: true)
ProdutoService produtoService(Ref ref) {
  final repository = ref.watch(produtoRepositoryProvider);
  return ProdutoService(produtoRepository: repository);
}
