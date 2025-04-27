import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pegue_o_doce/menu/controllers/dados_usuario_controller.dart';
import 'package:pegue_o_doce/pedido/controllers/historico_pedido_controller.dart';
import 'package:pegue_o_doce/usuario/controllers/usuario_controller.dart';
import 'package:pegue_o_doce/usuario/services/usuario_service.dart';
import 'package:pegue_o_doce/usuario/views/cadastro_page.dart';
import 'package:pegue_o_doce/usuario/views/menu_principal_page.dart';
import 'package:pegue_o_doce/produto/controllers/produto_list_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends ConsumerState<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _senhaController;
  bool senhaVisivel = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FlutterCart carrinho = FlutterCart();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _senhaController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> realizarLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    bool retornoLogin =
        await ref.read(usuarioControllerProvider.notifier).login(
              _emailController.text.trim(),
              _senhaController.text.trim(),
              context,
            );

    if (!context.mounted) return;

    if (retornoLogin) {
      ref.invalidate(produtoListControllerProvider);
      ref.invalidate(historicoPedidoControllerProvider);
      ref.invalidate(dadosUsuarioControllerProvider);
      carrinho.clearCart();

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const MenuPrincipalPage(),
      ));
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
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _inicio(context),
                        _camposObrigatorios(context),
                        _senhaEsquecida(context),
                        _cadastro(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _cadastro(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Não possui uma conta?'),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CadastroPage(),
              ),
            );
          },
          child: const Text('Cadastre-se', textAlign: TextAlign.center),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  _senhaEsquecida(context) {
    return Center(
      child: TextButton(
        onPressed: () async {
          await ref
              .read(usuarioServiceProvider)
              .redefinirSenha(_emailController.text.trim(), context);
        },
        child: const Text('Esqueceu a senha? Preencha seu e-mail e clique aqui',
            textAlign: TextAlign.center),
      ),
    );
  }

  _inicio(context) {
    return SizedBox(
      child: Column(
        children: [
          Image.asset(
            "assets/images/logo.png",
            fit: BoxFit.cover,
            height: 250,
            width: 250,
          ),
          const Text(
            "Bem vindo ao app Pegue o Doce!",
            style: TextStyle(
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const Text("Faça login para continuar",
              style: TextStyle(
                fontSize: 16,
              )),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  _camposObrigatorios(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: "E-mail:",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            prefixIcon: const Icon(FontAwesomeIcons.at),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _senhaController,
          obscureText: !senhaVisivel,
          decoration: InputDecoration(
            labelText: "Senha:",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            prefixIcon: const Icon(FontAwesomeIcons.unlock),
            suffixIcon: IconButton(
              icon: Icon(
                senhaVisivel ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  senhaVisivel = !senhaVisivel;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () {
            realizarLogin(context);
          },
          child: const Text(
            "Entrar",
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
