import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:pegue_o_doce/empresa/controllers/dados_empresa_controller.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/pedido/views/encomenda_page.dart';
import 'package:pegue_o_doce/pedido/views/pedido_page.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/usuario/models/usuario_empresa.dart';
import 'package:pegue_o_doce/usuario/repositories/usuario_empresa_repository.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:pegue_o_doce/utils/tema.dart';
import 'package:pegue_o_doce/utils/widget_utils.dart';
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

  String formatarChavePix(String chave) {
    if (chave.length <= 8) return chave;
    return '${chave.substring(0, 5)}****${chave.substring(chave.length - 4)}';
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
      appBar: Tema.padrao('Visualizar Empresa'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              cabecalho(),
              const SizedBox(height: 24),
              secaoAcoes(context),
              const SizedBox(height: 24),
              const Divider(),
              secaoProdutos(context, listaProdutos),
              const SizedBox(height: 24),
              const Divider(),
              secaoLocaisEntrega(),
            ],
          ),
        ),
      ),
    );
  }

  Widget cabecalho() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.grey, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              empresa.nomeFantasia,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(FontAwesomeIcons.circleInfo, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    empresa.descricao,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(FontAwesomeIcons.listOl, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  'Mínimo para encomenda: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('${empresa.quantidadeMinimaEncomenda} itens',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(FontAwesomeIcons.key, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Chave PIX: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Expanded(
                        child: Text(
                          formatarChavePix(empresa.chavePix),
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(FontAwesomeIcons.copy, size: 15),
                        tooltip: 'Copiar chave PIX',
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: empresa.chavePix));
                          WidgetUtils.showSnackbar(
                              mensagem: 'Chave copiada!',
                              context: context,
                              erro: false);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget secaoAcoes(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: MediaQuery.of(context).size.width /
          (MediaQuery.of(context).size.height / 5),
      children: [
        botaoAcao(
          label: "Pedido",
          icon: FontAwesomeIcons.cartShopping,
          color: Colors.red[400],
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PedidoPage(empresa: empresa),
              ),
            );
          },
        ),
        botaoAcao(
          label: "Encomenda",
          icon: FontAwesomeIcons.box,
          color: Colors.orange[600],
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EncomendaPage(empresa: empresa),
              ),
            );
          },
        ),
        botaoAcao(
          label: "Favoritar",
          icon: FontAwesomeIcons.star,
          color: Colors.yellow[700],
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => dialogoFavoritarEmpresa(context),
            );
          },
        ),
        botaoAcao(
          label: "Contato",
          icon: FontAwesomeIcons.whatsapp,
          color: Colors.green[600],
          onPressed: () {
            launchUrl(
              Uri.parse(
                  "https://wa.me/55$telefoneContato?text=Olá, gostaria de mais informações sobre seus produtos."),
            );
          },
        ),
      ],
    );
  }

  Widget botaoAcao({
    required String label,
    required IconData icon,
    required Color? color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: color),
    );
  }

  Widget secaoProdutos(
      BuildContext context, AsyncValue<List<Produto>> listaProdutos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(FontAwesomeIcons.utensils),
            SizedBox(width: 10),
            Text(
              "Produtos",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        listaProdutos.when(
          data: (produtos) => Column(
            children: produtos.map((produto) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(FontAwesomeIcons.utensils,
                      color: Colors.deepOrange),
                  title: Text(produto.descricao),
                  subtitle: Text(
                    FormatadorMoedaReal.formatarValorReal(
                        produto.valorUnitario),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          dialogoExibirDadosProduto(context, produto),
                    );
                  },
                ),
              );
            }).toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Erro: $error')),
        ),
      ],
    );
  }

  Widget secaoLocaisEntrega() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(FontAwesomeIcons.mapLocationDot),
            SizedBox(width: 10),
            Text(
              "Locais de Entrega:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Tooltip(
              message: "Clique no local para ver no mapa",
              child: Icon(FontAwesomeIcons.circleInfo,
                  size: 16, color: Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: empresa.locaisEntrega.map(buildLocalEntregaChip).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildLocalEntregaChip(local) {
    return GestureDetector(
      onTap: () => mostrarMapaLocalEntrega(context, local),
      child: Chip(
        avatar: const Icon(FontAwesomeIcons.locationDot,
            size: 16, color: Colors.blue),
        label: Text(local.nome),
        backgroundColor: Colors.blue[30],
        shadowColor: Colors.blue[200],
        elevation: 3,
      ),
    );
  }

  void mostrarMapaLocalEntrega(BuildContext context, local) {
    final mapController = MapController();
    const initialZoom = 16.0;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              local.nome,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              width: double.infinity,
              child: buildMapaComControles(
                  mapController, local.coordenadas, initialZoom),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMapaComControles(
      MapController mapController, LatLng coordenadas, double initialZoom) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: coordenadas,
              initialZoom: initialZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                tileProvider: CancellableNetworkTileProvider(),
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: coordenadas,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      FontAwesomeIcons.locationDot,
                      color: Colors.red,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Column(
            children: [
              FloatingActionButton(
                mini: true,
                heroTag: 'zoom_in_${coordenadas.latitude}',
                onPressed: () {
                  mapController.move(mapController.camera.center,
                      mapController.camera.zoom + 1);
                },
                child: const Icon(Icons.zoom_in),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                heroTag: 'zoom_out_${coordenadas.longitude}',
                onPressed: () {
                  mapController.move(mapController.camera.center,
                      mapController.camera.zoom - 1);
                },
                child: const Icon(Icons.zoom_out),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                heroTag: 'recenter_${coordenadas.latitude}',
                onPressed: () {
                  mapController.move(coordenadas, initialZoom);
                },
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }

  AlertDialog dialogoFavoritarEmpresa(BuildContext context) {
    return AlertDialog(
      title: const Icon(FontAwesomeIcons.star, color: Colors.yellow, size: 40),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Favoritar Empresa",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Deseja favoritar esta empresa?",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
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
              WidgetUtils.showSnackbar(
                  mensagem: 'Empresa já foi favoritada anteriormente.',
                  context: context,
                  erro: true);
            } else {
              WidgetUtils.showSnackbar(
                  mensagem: 'Empresa favoritada com sucesso!',
                  context: context,
                  erro: false);

              await ref
                  .read(dadosEmpresaControllerProvider.notifier)
                  .adicionarEmpresaFavorita(usuarioEmpresa);
            }

            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text("Confirmar"),
        ),
      ],
    );
  }

  AlertDialog dialogoExibirDadosProduto(BuildContext context, Produto produto) {
    return AlertDialog(
      title: const Text('Detalhes do produto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          padronizarTexto('Sabor', produto.sabor),
          padronizarTexto('Vegano', produto.vegano ? 'Sim' : 'Não'),
          padronizarTexto('Contém Glúten', produto.temGlutem ? 'Sim' : 'Não'),
          padronizarTexto('Contém Lactose', produto.temLactose ? 'Sim' : 'Não'),
          const SizedBox(height: 8),
          const Text('Alérgenos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...produto.alergenos.map((a) => Text('- $a')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Fechar"),
        ),
      ],
    );
  }

  Widget padronizarTexto(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: '$titulo: ',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: valor,
              style: const TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.black87),
            )
          ],
        ),
      ),
    );
  }
}
