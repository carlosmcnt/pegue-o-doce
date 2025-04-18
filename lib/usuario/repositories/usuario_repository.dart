import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/firebase/firebase.dart';
import 'package:pegue_o_doce/usuario/models/usuario.dart';

part 'usuario_repository.g.dart';

class UsuarioRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UsuarioRepository(this._auth, this._firestore);

  Future<dynamic> registrar({
    required String nomeCompleto,
    required String email,
    required String cpf,
    required String senha,
    required String telefone,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final user = userCredential.user;
      if (user == null) throw FirebaseAuthException(code: 'user-not-found');

      await _firestore.collection('usuarios').doc(user.uid).set({
        'nomeCompleto': nomeCompleto,
        'email': email,
        'cpf': cpf,
        'telefone': telefone,
        'dataCadastro': Timestamp.now(),
        'dataUltimaAlteracao': Timestamp.now(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'O e-mail informado já está em uso';
        default:
          return 'Erro ao registrar, tente novamente mais tarde';
      }
    }
  }

  Future<Usuario> obterUsuarioAtual() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        return Usuario.fromFirebase(user, doc.data()!);
      } else {
        return Usuario.fromFirebase(user, {});
      }
    }
    throw FirebaseAuthException(
        code: 'user-not-found', message: 'Usuário não encontrado');
  }

  Future<void> sair() async {
    await _auth.signOut();
  }

  Future<dynamic> entrar({
    required String email,
    required String senha,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      return true;
    } on FirebaseAuthException {
      return 'Erro ao fazer login, verifique suas credenciais e tente novamente';
    }
  }

  Future<dynamic> redefinirSenha({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      return true;
    } on FirebaseAuthException {
      return 'Não foi possível enviar o e-mail de redefinição de senha, verifique o e-mail informado e tente novamente';
    }
  }

  Future<String> obterIdUsuarioLogado() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return user.uid;
      } else {
        throw FirebaseAuthException(code: 'user-not-found');
      }
    } catch (e) {
      return 'Erro ao obter ID do usuário: $e';
    }
  }

  Future<void> atualizarUsuario(Usuario usuario) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('usuarios').doc(user.uid).update({
        'nomeCompleto': usuario.nomeCompleto,
        'telefone': usuario.telefone,
        'dataUltimaAlteracao': Timestamp.now(),
      });
    }
  }

  Future<Usuario> obterUsuarioPorId(String usuarioId) async {
    final doc = await _firestore.collection('usuarios').doc(usuarioId).get();
    if (doc.exists) {
      return Usuario.fromDocument(doc);
    } else {
      throw FirebaseAuthException(code: 'user-not-found');
    }
  }
}

@riverpod
UsuarioRepository usuarioRepository(Ref ref) {
  final FirebaseAuth auth = ref.watch(firebaseAuthProvider);
  final FirebaseFirestore firestore = ref.watch(firebaseFirestoreProvider);
  return UsuarioRepository(auth, firestore);
}
