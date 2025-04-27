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

class DadosEmpresaPage extends ConsumerStatefulWidget {
  final Empresa empresa;

  const DadosEmpresaPage({super.key, required this.empresa});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return DadosEmpresaPageState();
  }
}

class DadosEmpresaPageState extends ConsumerState<DadosEmpresaPage> {
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
        builder: (context) => DadosEmpresaPage(empresa: empresa),
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

  @override
  Widget build(BuildContext context) {
    final listaProdutos = ref.watch(dadosEmpresaControllerProvider);

    final produtosAgrupados = agruparProdutosPorTipo(listaProdutos.value ?? []);

    return Scaffold(
      appBar: Tema.padrao('Minha Empresa'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                        Text('LOCAIS DE ENTREGA:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: empresa.locaisEntrega
                          .map<Widget>((local) => Chip(
                              label: Text(local),
                              backgroundColor: Colors.blue[50]))
                          .toList(),
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
                  label: 'Novo Produto',
                  color: Colors.green,
                  onTap: () {
                    abrirPaginaIncluirEditarProduto();
                  },
                ),
                botaoAcaoEmpresa(
                  icon: FontAwesomeIcons.penToSquare,
                  label: 'Editar Empresa',
                  color: Colors.orange,
                  onTap: () {
                    abrirPaginaEditarEmpresa();
                  },
                ),
                botaoAcaoEmpresa(
                  icon: FontAwesomeIcons.clockRotateLeft,
                  label: 'Histórico de Pedidos',
                  color: Colors.purple,
                  onTap: () {
                    abrirPaginaHistoricoPedido();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 2,
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
                          leading: const Icon(FontAwesomeIcons.utensils,
                              color: Colors.deepOrange),
                          title: Text(produto.sabor),
                          subtitle: Text(FormatadorMoedaReal.formatarValorReal(
                              produto.valorUnitario)),
                          trailing: const Icon(Icons.edit),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProdutoEditPage(
                                  produto: produto,
                                  empresa: empresa,
                                ),
                              ),
                            );
                          },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
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

  Widget organizarProdutosPorTipo(
      BuildContext context, String tipo, List<Produto> produtos) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tipo.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Column(
              children: produtos
                  .map(
                    (produto) => ListTile(
                      leading: const Icon(FontAwesomeIcons.box),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      title: Text(produto.sabor,
                          style: const TextStyle(fontSize: 20)),
                      subtitle: Text(
                          FormatadorMoedaReal.formatarValorReal(
                              produto.valorUnitario),
                          style: const TextStyle(fontSize: 16)),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProdutoEditPage(
                            produto: produto,
                            empresa: empresa,
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Excluir Produto'),
                              content: const Text(
                                  'Tem certeza que deseja excluir este produto?'),
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
                                        .read(produtoListControllerProvider
                                            .notifier)
                                        .deletarProduto(produto);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Produto excluído com sucesso!'),
                                      ),
                                    );

                                    atualizarPagina();
                                  },
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
