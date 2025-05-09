import 'package:pegue_o_doce/pergunta/models/perguntas_frequentes.dart';
import 'package:pegue_o_doce/pergunta/services/perguntas_frequentes_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'perguntas_frequentes_controller.g.dart';

@riverpod
class PerguntasFrequentesController extends _$PerguntasFrequentesController {
  @override
  Future<List<PerguntasFrequentes>> build() async {
    state = const AsyncValue.loading();
    try {
      final perguntasFrequentes = await ref
          .read(perguntasFrequentesServiceProvider)
          .obterPerguntasFrequentesAtivas();
      state = AsyncValue.data(perguntasFrequentes);
      return perguntasFrequentes;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return [];
    }
  }
}
