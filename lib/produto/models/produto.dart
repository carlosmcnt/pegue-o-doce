import 'package:cloud_firestore/cloud_firestore.dart';

class Produto {
  final String? id;
  final String descricao;
  final double valorUnitario;
  final String tipo;
  final String sabor;
  final bool temGluten;
  final bool temLactose;
  final bool vegano;
  final List<String> alergenos;
  final String empresaId;
  final String categoriaId;
  final Timestamp dataCadastro;
  final Timestamp dataUltimaAlteracao;

  Produto(
      {this.id,
      required this.descricao,
      required this.valorUnitario,
      required this.tipo,
      required this.sabor,
      this.temGluten = false,
      this.temLactose = false,
      this.vegano = false,
      required this.alergenos,
      required this.empresaId,
      required this.categoriaId,
      required this.dataCadastro,
      required this.dataUltimaAlteracao});

  factory Produto.empty(String empresaId) {
    return Produto(
      id: null,
      descricao: '',
      valorUnitario: 0.0,
      tipo: '',
      sabor: '',
      temGluten: false,
      temLactose: false,
      vegano: false,
      alergenos: [],
      empresaId: empresaId,
      categoriaId: '',
      dataCadastro: Timestamp.now(),
      dataUltimaAlteracao: Timestamp.now(),
    );
  }

  factory Produto.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Produto(
      id: doc.id,
      descricao: data['descricao'] ?? '',
      valorUnitario: (data['valorUnitario'] ?? 0.0).toDouble(),
      tipo: data['tipo'] ?? '',
      sabor: data['sabor'] ?? '',
      dataCadastro: data['dataCadastro'],
      temGluten: data['temGluten'] ?? false,
      temLactose: data['temLactose'] ?? false,
      vegano: data['vegano'] ?? false,
      alergenos: List<String>.from(data['alergenos'] ?? []),
      empresaId: data['empresaId'] ?? '',
      categoriaId: data['categoriaId'] ?? '',
      dataUltimaAlteracao: data['dataUltimaAlteracao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'valorUnitario': valorUnitario,
      'tipo': tipo,
      'sabor': sabor,
      'dataCadastro': dataCadastro,
      'temGluten': temGluten,
      'temLactose': temLactose,
      'vegano': vegano,
      'alergenos': alergenos,
      'empresaId': empresaId,
      'categoriaId': categoriaId,
      'dataUltimaAlteracao': dataUltimaAlteracao,
    };
  }

  Produto copyWith({
    String? id,
    String? descricao,
    double? valorUnitario,
    String? tipo,
    String? sabor,
    bool? temGluten,
    bool? temLactose,
    bool? vegano,
    List<String>? alergenos,
    String? empresaId,
    String? categoriaId,
    Timestamp? dataCadastro,
    Timestamp? dataUltimaAlteracao,
  }) {
    return Produto(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valorUnitario: valorUnitario ?? this.valorUnitario,
      tipo: tipo ?? this.tipo,
      sabor: sabor ?? this.sabor,
      temGluten: temGluten ?? this.temGluten,
      temLactose: temLactose ?? this.temLactose,
      vegano: vegano ?? this.vegano,
      alergenos: alergenos ?? this.alergenos,
      empresaId: empresaId ?? this.empresaId,
      categoriaId: categoriaId ?? this.categoriaId,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      dataUltimaAlteracao: dataUltimaAlteracao ?? this.dataUltimaAlteracao,
    );
  }
}
