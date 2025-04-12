import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioEmpresa {
  final String? id;
  final String usuarioId;
  final String empresaId;

  UsuarioEmpresa({this.id, required this.usuarioId, required this.empresaId});

  factory UsuarioEmpresa.fromDocument(DocumentSnapshot doc) {
    return UsuarioEmpresa(
      id: doc.id,
      usuarioId: doc['usuarioId'],
      empresaId: doc['empresaId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'empresaId': empresaId,
    };
  }
}
