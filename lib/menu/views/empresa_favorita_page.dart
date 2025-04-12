import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/menu/controllers/empresa_favorita_controller.dart';
import 'package:pegue_o_doce/menu/views/menu_lateral.dart';
import 'package:pegue_o_doce/utils/tema.dart';
import 'package:pegue_o_doce/empresa/views/visualizacao_empresa.dart';

class EmpresaFavoritaPage extends ConsumerStatefulWidget {
  const EmpresaFavoritaPage({super.key});

  @override
  ConsumerState<EmpresaFavoritaPage> createState() {
    return EmpresaFavoritaPageState();
  }
}

class EmpresaFavoritaPageState extends ConsumerState<EmpresaFavoritaPage> {
  late Future<List<Empresa>> listaEmpresas;

  Future<List<Empresa>> obterListaEmpresasFavoritas() {
    return ref
        .read(empresaFavoritaControllerProvider.notifier)
        .obterListaEmpresasFavoritasPorUsuarioLogado();
  }

  @override
  void initState() {
    super.initState();
    listaEmpresas = obterListaEmpresasFavoritas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.descricaoAcoes('Minhas Empresas Favoritas', []),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder<List<Empresa>>(
                    future: listaEmpresas,
                    builder: (context, snapshot) {
                      return _buildListaEmpresas(context, snapshot);
                    },
                  ),
                ),
              ],
            ),
          )),
      drawer: const MenuLateralWidget(),
    );
  }

  Widget _buildListaEmpresas(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData && snapshot.data.isNotEmpty) {
        final empresas = snapshot.data as List<Empresa>;
        return ListView.builder(
          itemCount: empresas.length,
          itemBuilder: (context, index) {
            final empresa = empresas[index];
            return Card(
              child: ListTile(
                leading: const Icon(FontAwesomeIcons.buildingCircleCheck),
                title: Text(empresa.nomeFantasia),
                subtitle: Text(empresa.descricao),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          VisualizacaoEmpresaPage(empresa: empresa)));
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          alertaRemocaoEmpresaFavorita(context, empresa),
                    );
                  },
                ),
              ),
            );
          },
        );
      } else {
        return const Center(
          child: Text(
            textAlign: TextAlign.center,
            'Nenhuma empresa favorita encontrada',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  AlertDialog alertaRemocaoEmpresaFavorita(
      BuildContext context, Empresa empresa) {
    return AlertDialog(
      title:
          const Icon(FontAwesomeIcons.heartCrack, color: Colors.red, size: 50),
      content: Text(
          'Deseja realmente remover a empresa ${empresa.nomeFantasia} dos favoritos?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            await ref
                .read(empresaFavoritaControllerProvider.notifier)
                .removerEmpresaFavorita(empresa.id!);
            setState(() {
              listaEmpresas = obterListaEmpresasFavoritas();
            });
            if (!context.mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Empresa removida dos favoritos'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Remover'),
        ),
      ],
    );
  }
}
