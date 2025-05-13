import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/empresa/controllers/dados_empresa_controller.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/empresa/views/empresa_edit_page.dart';
import 'package:pegue_o_doce/menu/views/menu_lateral.dart';
import 'package:pegue_o_doce/pedido/views/historico_pedido_page.dart';
import 'package:pegue_o_doce/produto/controllers/produto_list_controller.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/produto/views/produto_edit_page.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:pegue_o_doce/utils/tema.dart';

class PerfilEmpresaPage extends ConsumerStatefulWidget {
  final Empresa empresa;

  const PerfilEmpresaPage({super.key, required this.empresa});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return PerfilEmpresaPageState();
  }
}

class PerfilEmpresaPageState extends ConsumerState<PerfilEmpresaPage> {
  Empresa get empresa => widget.empresa;

  @override
  void initState() {
    super.initState();
  }

  Map<String, List<Produto>> agruparProdutosPorTipo(List<Produto> produtos) {
    final listaAgrupados = <String, List<Produto>>{};
    for (final produto in produtos) {
      if (!listaAgrupados.containsKey(produto.tipo)) {
        listaAgrupados[produto.tipo] = [];
      }
      listaAgrupados[produto.tipo]!.add(produto);
    }
    return listaAgrupados;
  }

  void atualizarPagina() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PerfilEmpresaPage(empresa: empresa),
      ),
    );
  }

  void abrirPaginaHistoricoPedido() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              const HistoricoPedidoPage(isHistoricoEmpresa: true)),
    );
  }

  void abrirPaginaIncluirEditarProduto() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProdutoEditPage(
          produto: Produto.empty(empresa.id!),
          empresa: empresa,
        ),
      ),
    );
  }

  void abrirPaginaEditarEmpresa() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmpresaEditPage(
          empresa: empresa,
        ),
      ),
    );
  }

  void deletarProduto(Produto produto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            const Icon(FontAwesomeIcons.trashCan, color: Colors.red, size: 40),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Excluir Produto",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Tem certeza que deseja excluir este produto?",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(produtoListControllerProvider.notifier)
                  .deletarProduto(produto);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produto excluído com sucesso!'),
                ),
              );

              atualizarPagina();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listaProdutos = ref.watch(dadosEmpresaControllerProvider);

    final produtosAgrupados = agruparProdutosPorTipo(listaProdutos.value ?? []);

    return Scaffold(
      appBar: Tema.padrao('Perfil Empresa'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      empresa.nomeFantasia,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(FontAwesomeIcons.circleInfo,
                            color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            empresa.descricao,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(FontAwesomeIcons.locationDot,
                            color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text('LOCAIS DE ENTREGA ATUAIS:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        children: empresa.locaisEntrega
                            .map<Widget>((local) => Chip(
                                label: Text(local.nome,
                                    style:
                                        const TextStyle(color: Colors.black)),
                                backgroundColor: Colors.blue[50]))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.height / 2.5),
              children: [
                botaoAcaoEmpresa(
                  icon: FontAwesomeIcons.circlePlus,
                  label: 'Cadastro de Produto',
                  color: Colors.green,
                  onTap: () {
                    abrirPaginaIncluirEditarProduto();
                  },
                ),
                botaoAcaoEmpresa(
                  icon: FontAwesomeIcons.penToSquare,
                  label: 'Edição de Empresa',
                  color: Colors.orange,
                  onTap: () {
                    abrirPaginaEditarEmpresa();
                  },
                ),
                botaoAcaoEmpresa(
                  icon: FontAwesomeIcons.clockRotateLeft,
                  label: 'Histórico de Vendas',
                  color: Colors.purple,
                  onTap: () {
                    abrirPaginaHistoricoPedido();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(
              color: Colors.black,
              thickness: 1.5,
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Produtos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            ...produtosAgrupados.entries.map((entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key.toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      ...entry.value.map((produto) {
                        return ListTile(
                          isThreeLine: true,
                          leading: const Icon(FontAwesomeIcons.utensils,
                              color: Colors.deepOrange),
                          title: Text('Sabor: ${produto.sabor}'),
                          subtitle: Text(
                              FormatadorMoedaReal.formatarValorReal(
                                  produto.valorUnitario),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Editar Produto',
                                icon: Icon(FontAwesomeIcons.penToSquare,
                                    color: Colors.yellow[800]),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProdutoEditPage(
                                        produto: produto,
                                        empresa: empresa,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'Excluir Produto',
                                icon: const Icon(FontAwesomeIcons.trashCan,
                                    color: Colors.red),
                                onPressed: () {
                                  deletarProduto(produto);
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      drawer: const MenuLateralWidget(),
    );
  }

  Widget botaoAcaoEmpresa({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color.withValues(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
