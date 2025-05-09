import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pegue_o_doce/menu/views/menu_lateral.dart';
import 'package:pegue_o_doce/pergunta/controllers/perguntas_frequentes_controller.dart';
import 'package:pegue_o_doce/pergunta/models/perguntas_frequentes.dart';
import 'package:pegue_o_doce/utils/tema.dart';

class PerguntasFrequentesPage extends ConsumerStatefulWidget {
  const PerguntasFrequentesPage({super.key});

  @override
  ConsumerState<PerguntasFrequentesPage> createState() {
    return PerguntasFrequentesPageState();
  }
}

class PerguntasFrequentesPageState
    extends ConsumerState<PerguntasFrequentesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.padrao(
        'Perguntas Frequentes',
      ),
      body: FutureBuilder<List<PerguntasFrequentes>>(
        future: ref.watch(perguntasFrequentesControllerProvider.future),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma pergunta encontrada.'));
          } else {
            final perguntasFrequentes = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: perguntasFrequentes.length,
              itemBuilder: (context, index) {
                final item = perguntasFrequentes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ExpandablePanel(
                    theme: const ExpandableThemeData(
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      tapBodyToCollapse: true,
                      hasIcon: true,
                      iconColor: Colors.green,
                    ),
                    header: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        item.pergunta,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    collapsed: const SizedBox.shrink(),
                    expanded: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Text(
                        item.resposta,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      drawer: const MenuLateralWidget(),
    );
  }
}
