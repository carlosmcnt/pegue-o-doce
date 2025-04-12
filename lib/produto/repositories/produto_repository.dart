import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/firebase/firebase.dart';

part 'produto_repository.g.dart';

class ProdutoRepository {
  final FirebaseFirestore _firestore;

  ProdutoRepository(this._firestore);

  Future<Produto?> getProdutoPorId(String id) async {
    final snapshot = await _firestore.collection('produtos').doc(id).get();
    if (snapshot.exists) {
      return Produto.fromDocument(snapshot);
    }
    return null;
  }

  Stream<List<Produto>> getProdutos() {
    return _firestore.collection('produtos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Produto.fromDocument(doc)).toList();
    });
  }

  Future<List<Produto>> getProdutosPorEmpresa(String empresaId) async {
    return _firestore
        .collection('produtos')
        .where('empresaId', isEqualTo: empresaId)
        .get()
        .then((snapshot) {
      return snapshot.docs.map((doc) => Produto.fromDocument(doc)).toList();
    });
  }

  Future<Produto> inserirProduto(Produto produto) async {
    final docRef = await _firestore.collection('produtos').add(produto.toMap());
    return produto.copyWith(id: docRef.id);
  }

  Future<void> atualizarProduto(Produto produto) async {
    await _firestore
        .collection('produtos')
        .doc(produto.id)
        .update(produto.toMap());
  }

  Future<void> deletarProduto(String id) async {
    await _firestore.collection('produtos').doc(id).delete();
  }

  Future<List<Produto?>> obterProdutosPorCategoria(String categoriaId) async {
    final snapshot = await _firestore
        .collection('produtos')
        .where('categoriaId', isEqualTo: categoriaId)
        .get();
    return snapshot.docs.map((doc) => Produto.fromDocument(doc)).toList();
  }

  Future<List<Produto>> obterProdutosPorTipo(String tipo) async {
    final snapshot = await _firestore
        .collection('produtos')
        .where('tipo', isEqualTo: tipo)
        .get();
    return snapshot.docs.map((doc) => Produto.fromDocument(doc)).toList();
  }

  Future<List<String>> obterTiposDeProduto() async {
    final snapshot = await _firestore.collection('produtos').get();
    return snapshot.docs.map((doc) => doc['tipo'] as String).toSet().toList();
  }
}

@riverpod
ProdutoRepository produtoRepository(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return ProdutoRepository(firestore);
}
