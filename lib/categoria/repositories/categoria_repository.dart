import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/categoria/models/categoria.dart';
import 'package:pegue_o_doce/firebase/firebase.dart';

part 'categoria_repository.g.dart';

class CategoriaRepository {
  final FirebaseFirestore _firestore;

  CategoriaRepository(this._firestore);

  Future<List<Categoria>> getCategoriasAtivas() {
    return _firestore
        .collection('categorias')
        .where('ativo', isEqualTo: true)
        .get()
        .then((query) {
      return query.docs.map((doc) => Categoria.fromDocument(doc)).toList();
    });
  }

  Future<String> getNomeCategoria(String id) {
    return _firestore.collection('categorias').doc(id).get().then((doc) {
      return Categoria.fromDocument(doc).nome;
    });
  }

  Future<String> getDescricaoCategoria(String id) {
    return _firestore.collection('categorias').doc(id).get().then((doc) {
      return Categoria.fromDocument(doc).descricao;
    });
  }

  Future<Categoria> getCategoriaPorIdProduto(String idProduto) {
    return _firestore
        .collection('produtos')
        .doc(idProduto)
        .get()
        .then((doc) async {
      final idCategoria = doc.data()!['categoria'] as String;
      final categoriaDoc =
          await _firestore.collection('categorias').doc(idCategoria).get();
      return Categoria.fromDocument(categoriaDoc);
    });
  }
}

@riverpod
CategoriaRepository categoriaRepository(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return CategoriaRepository(firestore);
}
