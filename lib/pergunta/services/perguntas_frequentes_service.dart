import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pegue_o_doce/pergunta/models/perguntas_frequentes.dart';
import 'package:pegue_o_doce/pergunta/repositories/perguntas_frequentes_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'perguntas_frequentes_service.g.dart';

class PerguntasFrequentesService {
  final PerguntasFrequentesRepository perguntasFrequentesRepository;

  PerguntasFrequentesService({required this.perguntasFrequentesRepository});

  Future<List<PerguntasFrequentes>> obterPerguntasFrequentesAtivas() async {
    return await perguntasFrequentesRepository.obterPerguntasFrequentesAtivas();
  }
}

@Riverpod(keepAlive: true)
PerguntasFrequentesService perguntasFrequentesService(Ref ref) {
  final repository = ref.watch(perguntasFrequentesRepositoryProvider);
  return PerguntasFrequentesService(perguntasFrequentesRepository: repository);
}
