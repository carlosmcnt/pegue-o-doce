import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pegue_o_doce/empresa/models/local_entrega.dart';

class Empresa {
  final String? id;
  final String usuarioId;
  final String nomeFantasia;
  final String chavePix;
  final String descricao;
  final int quantidadeMinimaEncomenda;
  final List<LocalEntrega> locaisEntrega;
  final Timestamp dataCadastro;
  final Timestamp dataUltimaAlteracao;

  Empresa(
      {this.id,
      required this.nomeFantasia,
      required this.usuarioId,
      required this.chavePix,
      required this.descricao,
      required this.quantidadeMinimaEncomenda,
      required this.locaisEntrega,
      required this.dataCadastro,
      required this.dataUltimaAlteracao});

  factory Empresa.empty(String usuarioId) {
    return Empresa(
      nomeFantasia: '',
      usuarioId: usuarioId,
      chavePix: '',
      descricao: '',
      quantidadeMinimaEncomenda: 0,
      locaisEntrega: [],
      dataCadastro: Timestamp.now(),
      dataUltimaAlteracao: Timestamp.now(),
    );
  }

  factory Empresa.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Empresa(
      id: doc.id,
      nomeFantasia: data['nomeFantasia'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      chavePix: data['chavePix'] ?? '',
      descricao: data['descricao'] ?? '',
      quantidadeMinimaEncomenda: data['quantidadeMinimaEncomenda'] ?? 0,
      locaisEntrega: (data['locaisEntrega'] as List<dynamic>?)
              ?.map((e) => LocalEntrega.fromMap(e))
              .toList() ??
          [],
      dataCadastro: data['dataCadastro'],
      dataUltimaAlteracao: data['dataUltimaAlteracao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomeFantasia': nomeFantasia,
      'usuarioId': usuarioId,
      'chavePix': chavePix,
      'descricao': descricao,
      'quantidadeMinimaEncomenda': quantidadeMinimaEncomenda,
      'locaisEntrega': locaisEntrega.map((local) => local.toMap()).toList(),
      'dataCadastro': dataCadastro,
      'dataUltimaAlteracao': dataUltimaAlteracao,
    };
  }

  Empresa copyWith({
    String? id,
    String? usuarioId,
    String? nomeFantasia,
    String? chavePix,
    String? descricao,
    int? quantidadeMinimaEncomenda,
    List<LocalEntrega>? locaisEntrega,
    Timestamp? dataCadastro,
    Timestamp? dataUltimaAlteracao,
  }) {
    return Empresa(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nomeFantasia: nomeFantasia ?? this.nomeFantasia,
      chavePix: chavePix ?? this.chavePix,
      descricao: descricao ?? this.descricao,
      quantidadeMinimaEncomenda:
          quantidadeMinimaEncomenda ?? this.quantidadeMinimaEncomenda,
      locaisEntrega: locaisEntrega ?? this.locaisEntrega,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      dataUltimaAlteracao: dataUltimaAlteracao ?? this.dataUltimaAlteracao,
    );
  }
}
