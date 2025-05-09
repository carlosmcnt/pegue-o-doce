import 'package:cloud_firestore/cloud_firestore.dart';

class PerguntasFrequentes {
  final String? id;
  final String pergunta;
  final String resposta;
  final bool ativo;

  PerguntasFrequentes({
    this.id,
    required this.pergunta,
    required this.resposta,
    this.ativo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'pergunta': pergunta,
      'resposta': resposta,
      'ativo': ativo,
    };
  }

  factory PerguntasFrequentes.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PerguntasFrequentes(
      id: doc.id,
      pergunta: data['pergunta'] ?? '',
      resposta: data['resposta'] ?? '',
      ativo: data['ativo'] ?? true,
    );
  }
}
