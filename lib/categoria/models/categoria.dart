import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Categoria {
  final String? id;
  final String nome;
  final String descricao;
  final IconData? icone;
  final bool ativo;

  Categoria({
    this.id,
    required this.nome,
    required this.descricao,
    required this.icone,
    this.ativo = true,
  });

  factory Categoria.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Categoria(
      id: doc.id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      icone: data['icone'] != null
          ? obterIconePeloNome(data['icone'])
          : FontAwesomeIcons.store,
      ativo: data['ativo'] ?? true,
    );
  }

  static IconData? obterIconePeloNome(String iconName) {
    final iconMap = {
      'doce': FontAwesomeIcons.candyCane,
      'hamburguer': FontAwesomeIcons.burger,
      'salgado': FontAwesomeIcons.hotdog,
      'bebida': FontAwesomeIcons.glassWater,
      'pizza': FontAwesomeIcons.pizzaSlice,
      'sorvete': FontAwesomeIcons.iceCream,
      'saudavel': FontAwesomeIcons.carrot,
    };
    return iconMap[iconName];
  }
}
