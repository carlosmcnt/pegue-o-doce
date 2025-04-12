import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/empresa/controllers/empresa_edit_controller.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/empresa/views/dados_empresa.dart';
import 'package:pegue_o_doce/usuario/services/usuario_service.dart';
import 'package:pegue_o_doce/utils/tema.dart';
import 'package:pegue_o_doce/utils/validador.dart';
import 'package:pegue_o_doce/utils/formatador.dart';

class EmpresaEditPage extends ConsumerStatefulWidget {
  final Empresa empresa;

  const EmpresaEditPage({super.key, required this.empresa});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return EmpresaEditPageState();
  }
}

class EmpresaEditPageState extends ConsumerState<EmpresaEditPage> {
  late TextEditingController _nomeFantasiaController;
  late TextEditingController _chavePixController;
  late TextEditingController _descricaoController;
  late TextEditingController _locaisEntregaController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<String> _locaisEntrega = [];
  late String tipoChavePix = '';
  bool ignorarTipoChavePix = false;

  Empresa get empresa => widget.empresa;

  @override
  void initState() {
    super.initState();
    _nomeFantasiaController = TextEditingController(text: empresa.nomeFantasia);
    _chavePixController = TextEditingController(text: empresa.chavePix);
    _descricaoController = TextEditingController(text: empresa.descricao);
    _locaisEntregaController = TextEditingController();
    _locaisEntrega = List<String>.from(empresa.locaisEntrega);
    if (_nomeFantasiaController.text.isNotEmpty) {
      ignorarTipoChavePix = true;
    }
  }

  @override
  void dispose() {
    _nomeFantasiaController.dispose();
    _chavePixController.dispose();
    _descricaoController.dispose();
    _locaisEntregaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.descricaoAcoes('Incluir/Editar Empresa', []),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nomeFantasiaController,
                  maxLength: 40,
                  decoration: InputDecoration(
                    labelText: 'Nome Fantasia:',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(FontAwesomeIcons.building),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome Fantasia é obrigatório';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FormatadorLetrasMaiusculas(),
                  ],
                ),
                const SizedBox(height: 15),
                DropdownMenu<String>(
                  label: const Text('Tipo de chave PIX:'),
                  leadingIcon: const Icon(Icons.key),
                  dropdownMenuEntries: Validador().listaTiposChavesPix(),
                  width: MediaQuery.sizeOf(context).width,
                  initialSelection:
                      empresa.chavePix.isNotEmpty ? empresa.chavePix : '',
                  onSelected: (value) {
                    setState(() {
                      tipoChavePix = value!;
                      _chavePixController.clear();
                    });
                  },
                  requestFocusOnTap: false,
                  enableSearch: false,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _chavePixController,
                  maxLength: 32,
                  decoration: InputDecoration(
                    labelText: 'Valor da chave PIX:',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(FontAwesomeIcons.qrcode),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpar campo',
                      onPressed: () {
                        _chavePixController.clear();
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O valor da chave é obrigatório';
                    }
                    if (ignorarTipoChavePix) {
                      return null;
                    }
                    if (Validador.validarChavePixSelecionada(
                            value, tipoChavePix) ==
                        false) {
                      return 'Chave PIX inválida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  controller: _descricaoController,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: 'Descrição:',
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
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _locaisEntregaController,
                  decoration: InputDecoration(
                    labelText: 'Possíveis locais de entrega:',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(FontAwesomeIcons.mapLocationDot),
                    helperText:
                        'Ex: PAF II, Instituto de Biologia, Faculdade de Educação',
                    helperMaxLines: 2,
                    suffixIcon: IconButton(
                      icon: const Icon(FontAwesomeIcons.circleCheck),
                      tooltip: 'Adicionar local de entrega',
                      onPressed: () {
                        final local = _locaisEntregaController.text.trim();
                        if (local.isNotEmpty) {
                          setState(() {
                            _locaisEntrega.add(local);
                            _locaisEntregaController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  inputFormatters: [
                    FormatadorLetrasMaiusculas(),
                  ],
                ),
                const SizedBox(height: 10),
                const SizedBox(
                  height: 30,
                  child: Text('Locais de entrega selecionados:',
                      style: TextStyle(fontSize: 15)),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (var local in _locaisEntrega)
                      Chip(
                        label: Text(local),
                        avatar: const Icon(FontAwesomeIcons.locationArrow),
                        deleteButtonTooltipMessage: 'Remover local de entrega',
                        onDeleted: () {
                          setState(() {
                            _locaisEntrega.remove(local);
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final usuarioLogado = await ref
                          .read(usuarioServiceProvider)
                          .obterUsuarioLogado();

                      final empresaNova = empresa.copyWith(
                        nomeFantasia: _nomeFantasiaController.text,
                        chavePix: _chavePixController.text,
                        descricao: _descricaoController.text,
                        locaisEntrega: _locaisEntrega,
                        usuarioId: usuarioLogado.id,
                      );

                      await ref
                          .read(empresaEditControllerProvider.notifier)
                          .inserirOuAtualizarEmpresa(empresaNova);

                      if (!context.mounted) return;

                      ref.invalidate(empresaEditControllerProvider);

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => DadosEmpresaPage(
                            empresa: empresaNova,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(empresa.id == null ? 'Cadastrar' : 'Atualizar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
