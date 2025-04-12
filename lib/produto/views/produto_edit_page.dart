import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/categoria/models/categoria.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/produto/controllers/produto_list_controller.dart';
import 'package:pegue_o_doce/produto/models/produto.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:pegue_o_doce/utils/tema.dart';

class ProdutoEditPage extends ConsumerStatefulWidget {
  final Produto produto;
  final Empresa empresa;

  const ProdutoEditPage(
      {super.key, required this.produto, required this.empresa});

  @override
  ConsumerState<ProdutoEditPage> createState() {
    return ProdutoEditPageState();
  }
}

class ProdutoEditPageState extends ConsumerState<ProdutoEditPage> {
  late TextEditingController _descricaoController;
  late TextEditingController _valorController;
  late TextEditingController _tipoController;
  late TextEditingController _saborController;
  late TextEditingController _alergenosController;
  late String _categoria = '';
  List<String> _alergenos = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _temLactose = false;
  bool _temGlutem = false;
  bool _vegano = false;
  Produto get produto => widget.produto;

  void carregarCategoria() {
    ref
        .read(produtoListControllerProvider.notifier)
        .buscarCategorias()
        .then((categorias) {
      final categoria = categorias.firstWhere(
          (element) => element.id == produto.categoriaId,
          orElse: () =>
              Categoria(id: '', descricao: '', nome: '', icone: null));
      _categoria = categoria.id!;
    });
  }

  @override
  void initState() {
    super.initState();
    carregarCategoria();
    _descricaoController = TextEditingController(text: produto.descricao);
    _valorController =
        TextEditingController(text: produto.valorUnitario.toString());
    _tipoController = TextEditingController(text: produto.tipo);
    _saborController = TextEditingController(text: produto.sabor);
    _alergenosController = TextEditingController();
    _temLactose = produto.temLactose;
    _temGlutem = produto.temGlutem;
    _vegano = produto.vegano;
    _alergenos = List<String>.from(produto.alergenos);
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _tipoController.dispose();
    _saborController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.descricaoAcoes('Incluir/Editar Produto', []),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  maxLength: 200,
                  controller: _descricaoController,
                  decoration: InputDecoration(
                    labelText: 'Descrição do produto:',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(FontAwesomeIcons.circleInfo),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Descrição é obrigatória';
                    }
                    return null;
                  },
                ),
              ),
              TextFormField(
                controller: _valorController,
                decoration: InputDecoration(
                  labelText: 'Valor Unitário:',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixText: 'R\$ ',
                  prefixIcon: const Icon(FontAwesomeIcons.moneyBillWave),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  FormatadorMoedaReal(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Valor unitário é obrigatório';
                  }
                  if (NormalizadorMoeda.normalizar(value) <= 0) {
                    return 'Valor unitário deve ser maior que zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Categoria>>(
                future: ref
                    .read(produtoListControllerProvider.notifier)
                    .buscarCategorias(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Erro ao carregar categorias');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Nenhuma categoria encontrada');
                  } else {
                    return DropdownMenu<String>(
                      label: const Text('Categoria do produto:'),
                      leadingIcon: const Icon(FontAwesomeIcons.tag),
                      initialSelection: _categoria,
                      dropdownMenuEntries: snapshot.data!
                          .map((categoria) => DropdownMenuEntry<String>(
                                value: categoria.id!,
                                label: categoria.nome,
                              ))
                          .toList(),
                      width: MediaQuery.sizeOf(context).width,
                      onSelected: (value) {
                        setState(() {
                          _categoria = value!;
                        });
                      },
                      enableSearch: false,
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _tipoController,
                decoration: InputDecoration(
                  labelText: 'Tipo do produto:',
                  hintText: 'Ex: Bolo, Torta, Salgado',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(FontAwesomeIcons.clipboardList),
                  suffixIcon: const Tooltip(
                    message:
                        'Para melhor visualização do agrupamento dos items na lista de produtos, utilize o mesmo nome do tipo para produtos semelhantes.',
                    child: Icon(FontAwesomeIcons.info),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tipo é obrigatório';
                  }
                  return null;
                },
                inputFormatters: [
                  FormatadorLetrasMaiusculas(),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _saborController,
                decoration: InputDecoration(
                  labelText: 'Sabor do produto:',
                  hintText: 'Ex: Chocolate, Morango, Ninho',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(FontAwesomeIcons.utensils),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sabor é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Row(
                  children: [
                    Icon(FontAwesomeIcons.breadSlice),
                    SizedBox(width: 10),
                    Text('Contém glútem?'),
                  ],
                ),
                value: _temGlutem,
                onChanged: (value) {
                  setState(() {
                    _temGlutem = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Row(
                  children: [
                    Icon(FontAwesomeIcons.cheese),
                    SizedBox(width: 10),
                    Text('Contém lactose?'),
                  ],
                ),
                value: _temLactose,
                onChanged: (value) {
                  setState(() {
                    _temLactose = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Row(
                  children: [
                    Icon(FontAwesomeIcons.seedling),
                    SizedBox(width: 10),
                    Text('Vegano?'),
                  ],
                ),
                value: _vegano,
                onChanged: (value) {
                  setState(() {
                    _vegano = value;
                  });
                },
              ),
              const Text('Possíveis componentes alérgenos:',
                  style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _alergenosController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Amendoim, Castanhas, Soja',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(FontAwesomeIcons.handDots),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final alergeno = _alergenosController.text.trim();
                      if (alergeno.isNotEmpty) {
                        setState(() {
                          _alergenos.add(alergeno);
                          _alergenosController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const SizedBox(
                height: 30,
                child: Text('Alérgenos selecionados:',
                    style: TextStyle(fontSize: 16)),
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (var alergeno in _alergenos)
                    Chip(
                      label: Text(alergeno),
                      onDeleted: () {
                        setState(() {
                          _alergenos.remove(alergeno);
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  final novoProduto = produto.copyWith(
                    descricao: _descricaoController.text,
                    valorUnitario:
                        NormalizadorMoeda.normalizar(_valorController.text),
                    tipo: _tipoController.text,
                    sabor: _saborController.text,
                    temGlutem: _temGlutem,
                    temLactose: _temLactose,
                    vegano: _vegano,
                    alergenos: _alergenos,
                    categoriaId: _categoria,
                    empresaId: widget.empresa.id!,
                  );

                  await ref
                      .read(produtoListControllerProvider.notifier)
                      .inserirOuAtualizarProduto(novoProduto);

                  ref.invalidate(produtoListControllerProvider);

                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: Text(produto.id == null ? 'Cadastrar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
