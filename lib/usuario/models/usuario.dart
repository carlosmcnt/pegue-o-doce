import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Usuario {
  final String? id;
  final String nomeCompleto;
  final String email;
  final String cpf;
  final String telefone;
  final Timestamp dataCadastro;
  final Timestamp dataUltimaAlteracao;

  Usuario(
      {this.id,
      required this.nomeCompleto,
      required this.email,
      required this.cpf,
      required this.telefone,
      required this.dataCadastro,
      required this.dataUltimaAlteracao});

  factory Usuario.fromFirebase(User firebaseUser, Map<String, dynamic> data) {
    return Usuario(
      id: firebaseUser.uid,
      nomeCompleto: data['nomeCompleto'],
      email: data['email'],
      cpf: data['cpf'],
      telefone: data['telefone'],
      dataCadastro: data['dataCadastro'],
      dataUltimaAlteracao: data['dataUltimaAlteracao'],
    );
  }

  factory Usuario.fromDocument(DocumentSnapshot doc) {
    return Usuario(
      id: doc.id,
      nomeCompleto: doc['nomeCompleto'],
      email: doc['email'],
      cpf: doc['cpf'],
      telefone: doc['telefone'],
      dataCadastro: doc['dataCadastro'],
      dataUltimaAlteracao: doc['dataUltimaAlteracao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomeCompleto': nomeCompleto,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'dataCadastro': dataCadastro,
      'dataUltimaAlteracao': dataUltimaAlteracao,
    };
  }

  Usuario copyWith({
    String? id,
    String? nomeCompleto,
    String? email,
    String? cpf,
    String? telefone,
    Timestamp? dataCadastro,
    Timestamp? dataUltimaAlteracao,
  }) {
    return Usuario(
      id: id ?? this.id,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      telefone: telefone ?? this.telefone,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      dataUltimaAlteracao: dataUltimaAlteracao ?? this.dataUltimaAlteracao,
    );
  }
}
