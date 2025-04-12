import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pegue_o_doce/usuario/views/login_page.dart';
import 'package:pegue_o_doce/usuario/views/menu_principal_page.dart';

class Roteador extends StatelessWidget {
  Roteador({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasData) {
              return const MenuPrincipalPage();
            } else {
              return const LoginPage();
            }
          }
        });
  }
}
