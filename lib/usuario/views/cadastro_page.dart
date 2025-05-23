import 'package:br_validators/br_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pegue_o_doce/usuario/controllers/usuario_controller.dart';
import 'package:pegue_o_doce/utils/formatador.dart';
import 'package:pegue_o_doce/utils/validador.dart';
import 'package:pegue_o_doce/utils/widget_utils.dart';

class CadastroPage extends ConsumerStatefulWidget {
  const CadastroPage({super.key});

  @override
  ConsumerState<CadastroPage> createState() {
    return CadastroPageState();
  }
}

class CadastroPageState extends ConsumerState<CadastroPage> {
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _cpfController;
  late TextEditingController _senhaController;
  late TextEditingController _repetirSenhaController;
  late TextEditingController _telefoneController;
  bool senhaVisivel = false;
  bool repetirSenhaVisivel = false;
  bool desabilitarBotao = false;
  AutovalidateMode validacaoTempoReal = AutovalidateMode.onUserInteraction;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _cpfController = TextEditingController();
    _senhaController = TextEditingController();
    _repetirSenhaController = TextEditingController();
    _telefoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _senhaController.dispose();
    _repetirSenhaController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> cadastrar(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => desabilitarBotao = true);

    final token = OneSignal.User.pushSubscription.id;

    if (token == null) {
      if (!context.mounted) return;
      WidgetUtils.showSnackbar(
          context: context,
          mensagem:
              "Erro ao obter o token de notificação. Tente novamente mais tarde.",
          erro: true);
      setState(() => desabilitarBotao = false);
      return;
    }

    bool retornoCadastro = await ref
        .read(usuarioControllerProvider.notifier)
        .cadastrar(
          _nomeController.text,
          _emailController.text,
          _senhaController.text,
          _cpfController.text,
          _telefoneController.text,
          token,
          context,
        )
        .whenComplete(() {
      setState(() => desabilitarBotao = false);
    });

    if (!context.mounted) return;

    if (retornoCadastro) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).shadowColor,
      body: Padding(
        padding: const EdgeInsets.all(36),
        child: Center(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _inicio(context),
                      _camposObrigatorios(context),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("Já possui uma conta?",
                              textAlign: TextAlign.center),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                "Faça o login",
                                textAlign: TextAlign.center,
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _inicio(context) {
    return Column(
      children: [
        Image.asset(
          "assets/images/logo.png",
          fit: BoxFit.cover,
          height: 250,
          width: 250,
        ),
        const Text(
          "Cadastre-se para continuar!",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        const Text("Preencha os campos abaixo para criar sua conta",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            )),
        const SizedBox(height: 50),
      ],
    );
  }

  _camposObrigatorios(context) {
    return Column(
      children: [
        TextFormField(
          controller: _nomeController,
          decoration: InputDecoration(
            labelText: "Nome:",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            filled: true,
            prefixIcon: const Icon(Icons.face),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, informe o nome';
            }
            return null;
          },
          inputFormatters: [
            FormatadorLetrasMaiusculas(),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: "E-mail:",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            prefixIcon: const Icon(FontAwesomeIcons.at),
          ),
          autovalidateMode: validacaoTempoReal,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, informe o e-mail';
            }
            if (!Validador.emailValido(value)) {
              return 'Por favor, informe um e-mail válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _cpfController,
          keyboardType: TextInputType.number,
          maxLength: 11,
          decoration: InputDecoration(
            labelText: "CPF:",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            prefixIcon: const Icon(FontAwesomeIcons.idCard),
          ),
          autovalidateMode: validacaoTempoReal,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, informe o CPF corretamente';
            }
            if (!BRValidators.validateCPF(value)) {
              return 'Por favor, informe um CPF válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _senhaController,
          obscureText: !senhaVisivel,
          decoration: InputDecoration(
            errorMaxLines: 2,
            labelText: "Senha:",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            prefixIcon: const Icon(FontAwesomeIcons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                senhaVisivel ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                setState(() {
                  senhaVisivel = !senhaVisivel;
                });
              },
            ),
          ),
          autovalidateMode: validacaoTempoReal,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, informe a senha';
            }
            if (!Validador.validarSenhaForte(value)) {
              return 'A senha deve ter pelo menos 8 caracteres, incluindo letras maiúsculas, minúsculas, números e símbolos';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _repetirSenhaController,
          obscureText: !repetirSenhaVisivel,
          decoration: InputDecoration(
            labelText: "Confirme a senha:",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            prefixIcon: const Icon(FontAwesomeIcons.lock),
          ),
          autovalidateMode: validacaoTempoReal,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, repita a senha';
            } else if (value != _senhaController.text) {
              return 'As senhas não conferem';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _telefoneController,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          decoration: InputDecoration(
            labelText: "Telefone (com DDD):",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.phone),
          ),
          autovalidateMode: validacaoTempoReal,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, informe o telefone';
            }
            if (!BRValidators.validateMobileNumber(
                Validador.aplicarMascaraTelefoneSemDDD(value))) {
              return 'Por favor, informe um telefone válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => cadastrar(context),
          child: desabilitarBotao
              ? const CircularProgressIndicator()
              : const Text(
                  "Cadastrar",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
        ),
      ],
    );
  }
}
