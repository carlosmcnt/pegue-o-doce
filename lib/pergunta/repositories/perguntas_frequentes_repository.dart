import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pegue_o_doce/firebase/firebase.dart';
import 'package:pegue_o_doce/pergunta/models/perguntas_frequentes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'perguntas_frequentes_repository.g.dart';

class PerguntasFrequentesRepository {
  final FirebaseFirestore _firestore;

  PerguntasFrequentesRepository(this._firestore);

  Future<List<PerguntasFrequentes>> obterPerguntasFrequentesAtivas() async {
    final snapshot = await _firestore
        .collection('perguntas_frequentes')
        .where('ativo', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => PerguntasFrequentes.fromDocument(doc))
        .toList();
  }
}

@riverpod
PerguntasFrequentesRepository perguntasFrequentesRepository(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return PerguntasFrequentesRepository(firestore);
}
