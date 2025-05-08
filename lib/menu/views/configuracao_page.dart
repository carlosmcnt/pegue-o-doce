import 'package:br_validators/br_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/empresa/views/dados_empresa.dart';
import 'package:pegue_o_doce/empresa/views/empresa_edit_page.dart';
import 'package:pegue_o_doce/menu/controllers/menu_lateral_controller.dart';
import 'package:pegue_o_doce/menu/views/menu_lateral.dart';
import 'package:pegue_o_doce/usuario/models/usuario.dart';
import 'package:pegue_o_doce/menu/controllers/dados_usuario_controller.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:pegue_o_doce/utils/tema.dart';
import 'package:pegue_o_doce/utils/widget_utils.dart';

class ConfiguracaoPage extends ConsumerStatefulWidget {
  const ConfiguracaoPage({super.key, required this.usuario});

  final Usuario usuario;

  @override
  ConsumerState<ConfiguracaoPage> createState() {
    return ConfiguracaoPageState();
  }
}

class ConfiguracaoPageState extends ConsumerState<ConfiguracaoPage> {
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _cpfController;
  late TextEditingController _telefoneController;
  Usuario get usuario => widget.usuario;
  bool habilitarEdicao = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: usuario.nomeCompleto);
    _emailController = TextEditingController(text: usuario.email);
    _cpfController = TextEditingController(text: usuario.cpf);
    _telefoneController = TextEditingController(text: usuario.telefone);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.padrao('Configurações'),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              WidgetUtils.textoInformacao(
                  'Para alterar os dados, clique no botão Editar. Após as alterações, clique em Salvar.'),
              const SizedBox(height: 15),
              ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: _nomeController,
                    enabled: habilitarEdicao,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                    ),
                    inputFormatters: [
                      FormatadorLetrasMaiusculas(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Tooltip(
                    message: 'E-mail não pode ser alterado',
                    child: TextFormField(
                      controller: _emailController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Tooltip(
                    message: 'CPF não pode ser alterado',
                    child: TextFormField(
                      controller: _cpfController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'CPF',
                      ),
                      validator: (value) => BRValidators.validateCPF(value!)
                          ? null
                          : 'CPF inválido',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _telefoneController,
                    enabled: habilitarEdicao,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) =>
                        BRValidators.validateMobileNumber(value!)
                            ? null
                            : 'Telefone inválido',
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      ElevatedButton.icon(
                        label: habilitarEdicao
                            ? const Text('Salvar')
                            : const Text('Editar'),
                        icon: const Icon(FontAwesomeIcons.check),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: habilitarEdicao
                              ? Colors.green
                              : const Color.fromARGB(255, 223, 202, 21),
                        ),
                        onPressed: () async {
                          setState(() {
                            habilitarEdicao = !habilitarEdicao;
                          });

                          if (!habilitarEdicao) {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  dialogoConfirmacaoAlteracao(context, ref),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        icon: const Icon(FontAwesomeIcons.xmark),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        label: const Text('Cancelar'),
                        onPressed: habilitarEdicao
                            ? () {
                                setState(() {
                                  habilitarEdicao = false;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  FutureBuilder<Empresa?>(
                      future: ref
                          .read(menuLateralControllerProvider.notifier)
                          .obterEmpresaLogada(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const SizedBox.shrink();
                        } else {
                          if (snapshot.data != null) {
                            return ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => DadosEmpresaPage(
                                        empresa: snapshot.data!),
                                  ),
                                );
                              },
                              icon: const Icon(FontAwesomeIcons.listCheck),
                              label: const Text('Acessar minha empresa'),
                            );
                          } else {
                            return ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return dialogoCriacaoEmpresa(context, ref);
                                  },
                                );
                              },
                              icon: const Icon(FontAwesomeIcons.moneyCheck),
                              label: const Text('Quero ser um vendedor'),
                            );
                          }
                        }
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
      drawer: const MenuLateralWidget(),
    );
  }

  AlertDialog dialogoCriacaoEmpresa(BuildContext context, WidgetRef ref) {
    final usuario =
        ref.watch(menuLateralControllerProvider).whenData((usuario) => usuario);
    return AlertDialog(
      title: const Icon(FontAwesomeIcons.building,
          color: Colors.greenAccent, size: 40),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Criação de Empresa",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Você ainda não possui um perfil de empresa. Deseja criar um agora?",
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
          child: const Text('Não'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => EmpresaEditPage(
                  empresa: Empresa.empty(usuario.valueOrNull?.id ?? ''),
                ),
              ),
            );
          },
          child: const Text('Sim'),
        ),
      ],
    );
  }

  AlertDialog dialogoConfirmacaoAlteracao(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Icon(FontAwesomeIcons.check, color: Colors.green, size: 40),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Alteração de Dados",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Deseja realmente confirmar as alterações?",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Usuario novoUsuario = usuario.copyWith(
              nomeCompleto: _nomeController.text,
              telefone: _telefoneController.text,
            );

            await ref
                .read(dadosUsuarioControllerProvider.notifier)
                .atualizarUsuario(novoUsuario);

            if (!context.mounted) return;

            ref.invalidate(menuLateralControllerProvider);
            ref.invalidate(dadosUsuarioControllerProvider);

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ConfiguracaoPage(
                  usuario: novoUsuario,
                ),
              ),
            );
          },
          child: const Text('Sim'),
        ),
        TextButton(
          onPressed: () {
            _nomeController.text = usuario.nomeCompleto;
            _telefoneController.text = usuario.telefone;
            Navigator.of(context).pop();
          },
          child: const Text('Não'),
        ),
      ],
    );
  }
}
