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
    return Column(
      children: [
        Text(
          empresa.nomeFantasia,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          empresa.descricao,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
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
          color: Colors.teal[600],
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
          color: Colors.red[600],
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
                    style: const TextStyle(color: Colors.grey),
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
              "Locais de entrega",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: empresa.locaisEntrega.map((local) {
            return Chip(
              avatar: const Icon(FontAwesomeIcons.locationDot, size: 16),
              label: Text(local),
              backgroundColor: Colors.blue[50],
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  AlertDialog dialogoFavoritarEmpresa(BuildContext context) {
    return AlertDialog(
      title: const Icon(FontAwesomeIcons.heartCircleExclamation,
          color: Colors.red, size: 50),
      content: const Text("Deseja favoritar esta empresa?"),
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
