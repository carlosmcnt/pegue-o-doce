import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/categoria/models/categoria.dart';
import 'package:pegue_o_doce/categoria/repositories/categoria_repository.dart';

part 'categoria_service.g.dart';

class CategoriaService {
  final CategoriaRepository categoriaRepository;

  CategoriaService({required this.categoriaRepository});

  Future<List<Categoria>> getCategoriasAtivas() {
    return categoriaRepository.getCategoriasAtivas();
  }

  Future<String> getNomeCategoria(String id) {
    return categoriaRepository.getNomeCategoria(id);
  }

  Future<String> getDescricaoCategoria(String id) {
    return categoriaRepository.getDescricaoCategoria(id);
  }

  Future<Categoria> getCategoriaPorIdProduto(String idProduto) {
    return categoriaRepository.getCategoriaPorIdProduto(idProduto);
  }
}

@Riverpod(keepAlive: true)
CategoriaService categoriaService(Ref ref) {
  final repository = ref.watch(categoriaRepositoryProvider);
  return CategoriaService(categoriaRepository: repository);
}
