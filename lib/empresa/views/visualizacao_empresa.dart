import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/empresa/controllers/dados_empresa_controller.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/pedido/views/encomenda_page.dart';
import 'package:pegue_o_doce/pedido/views/pedido_page.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/usuario/models/usuario_empresa.dart';
import 'package:pegue_o_doce/usuario/repositories/usuario_empresa_repository.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:pegue_o_doce/utils/tema.dart';
import 'package:url_launcher/url_launcher.dart';

class VisualizacaoEmpresaPage extends ConsumerStatefulWidget {
  final Empresa empresa;

  const VisualizacaoEmpresaPage({super.key, required this.empresa});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return VisualizacaoEmpresaPageState();
  }
}

class VisualizacaoEmpresaPageState
    extends ConsumerState<VisualizacaoEmpresaPage> {
  Empresa get empresa => widget.empresa;
  String? telefoneContato;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final listaProdutos = ref.watch(dadosEmpresaControllerProvider);
    ref
        .read(dadosEmpresaControllerProvider.notifier)
        .obterTelefoneContatoPorIdEmpresa(empresa.usuarioId)
        .then((telefone) {
      setState(() {
        telefoneContato = telefone;
      });
    });

    return Scaffold(
      appBar: Tema.descricaoAcoes('Visualizar Empresa', []),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  empresa.nomeFantasia,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(empresa.descricao, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PedidoPage(
                            empresa: empresa,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(FontAwesomeIcons.cartShopping),
                    label: const Text("Realizar Pedido"),
                  ),
                  ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EncomendaPage(
                              empresa: empresa,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(FontAwesomeIcons.box),
                      label: const Text("Encomendar")),
                  ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              dialogoFavoritarEmpresa(context),
                        );
                      },
                      icon: const Icon(FontAwesomeIcons.star),
                      label: const Text("Favoritar Empresa")),
                  ElevatedButton.icon(
                      onPressed: () {
                        launchUrl(
                          Uri.parse(
                              "https://wa.me/$telefoneContato?text=Olá, gostaria de mais informações sobre seus produtos."),
                        );
                      },
                      icon: const Icon(FontAwesomeIcons.whatsapp),
                      label: const Text("Entrar em contato")),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(FontAwesomeIcons.clipboardCheck),
                  SizedBox(width: 10),
                  Text(
                    "Produtos:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                children: listaProdutos.when(
                  data: (produtos) => produtos
                      .map((produto) => ListTile(
                            title: Text(produto.descricao),
                            subtitle: Text(
                                FormatadorMoedaReal.formatarValorReal(
                                    produto.valorUnitario)),
                            leading: const Icon(FontAwesomeIcons.circleInfo),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    exibirDadosProduto(produto),
                              );
                            },
                          ))
                      .toList(),
                  loading: () => const [CircularProgressIndicator()],
                  error: (e, stack) => [Text("Erro: $e")],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(FontAwesomeIcons.mapLocationDot),
                  SizedBox(width: 10),
                  Text(
                    "Local (is) de entrega:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: empresa.locaisEntrega
                    .map((local) => Chip(
                        label: Text(local),
                        avatar: const Icon(FontAwesomeIcons.locationArrow)))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AlertDialog dialogoFavoritarEmpresa(BuildContext context) {
    return AlertDialog(
      title: const Icon(FontAwesomeIcons.heartCircleExclamation,
          color: Colors.red, size: 50),
      content: const Text("Deseja favoritar esta empresa?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () async {
            final usuarioLogadoId = await ref
                .read(dadosEmpresaControllerProvider.notifier)
                .obterIdUsuarioLogado();

            UsuarioEmpresa usuarioEmpresa = UsuarioEmpresa(
              empresaId: empresa.id!,
              usuarioId: usuarioLogadoId,
            );

            bool existe = await ref
                .read(usuarioEmpresaRepositoryProvider)
                .existeUsuarioEmpresa(usuarioEmpresa);

            if (!context.mounted) return;

            if (existe) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Empresa já foi favoritada anteriormente.")),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Empresa favoritada com sucesso.")),
              );

              await ref
                  .read(dadosEmpresaControllerProvider.notifier)
                  .adicionarEmpresaFavoritaPagePage(usuarioEmpresa);
            }

            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text("Confirmar"),
        ),
      ],
    );
  }

  AlertDialog exibirDadosProduto(Produto produto) {
    return AlertDialog(
      title: const Text('Outros detalhes do produto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sabor:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          Text(produto.sabor, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Lista de alérgenos:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 8),
          ...produto.alergenos.map(
            (alergeno) => Text(
              alergeno,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Vegano: ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          Text(produto.vegano ? "Sim" : "Não",
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Sem Glúten: ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          Text(produto.temGlutem ? "Sim" : "Não",
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Sem Lactose: ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          Text(produto.temLactose ? "Sim" : "Não",
              style: const TextStyle(fontSize: 16)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Fechar"),
        ),
      ],
    );
  }
}
