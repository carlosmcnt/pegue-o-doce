import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/firebase/firebase.dart';
import 'package:pegue_o_doce/usuario/models/usuario_empresa.dart';

part 'usuario_empresa_repository.g.dart';

class UsuarioEmpresaRepository {
  final FirebaseFirestore _firestore;

  UsuarioEmpresaRepository(this._firestore);

  Future<void> adicionar(UsuarioEmpresa usuarioEmpresa) async {
    await _firestore.collection('usuario_empresa').add(usuarioEmpresa.toMap());
  }

  Future<void> removerEmpresaFavorita(
      String idUsuario, String idEmpresa) async {
    final query = await _firestore
        .collection('usuario_empresa')
        .where('usuarioId', isEqualTo: idUsuario)
        .where('empresaId', isEqualTo: idEmpresa)
        .get();

    for (final doc in query.docs) {
      await _firestore.collection('usuario_empresa').doc(doc.id).delete();
    }
  }

  Future<bool> existeUsuarioEmpresa(UsuarioEmpresa usuarioEmpresa) async {
    final query = await _firestore
        .collection('usuario_empresa')
        .where('usuarioId', isEqualTo: usuarioEmpresa.usuarioId)
        .where('empresaId', isEqualTo: usuarioEmpresa.empresaId)
        .get();

    return query.docs.isNotEmpty;
  }

  Future<List<UsuarioEmpresa>> obterEmpresasFavoritasPorUsuario(
      String usuarioId) async {
    final query = await _firestore
        .collection('usuario_empresa')
        .where('usuarioId', isEqualTo: usuarioId)
        .get();

    return query.docs.map((doc) => UsuarioEmpresa.fromDocument(doc)).toList();
  }
}

@riverpod
UsuarioEmpresaRepository usuarioEmpresaRepository(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return UsuarioEmpresaRepository(firestore);
}
