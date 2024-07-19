import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String? id;
  final String cliente;
  final String nome;
  final String raca;
  final String especie;
  final String idade;
  final String genero;
  final double peso;
  final String? alergias;
  final bool emTratamento;
  final String? imgUrl; // imgUrl é opcional

  PetModel({
    this.id,
    required this.cliente,
    required this.nome,
    required this.raca,
    required this.especie,
    required this.idade,
    required this.genero,
    required this.peso,
    this.alergias,
    required this.emTratamento,
    this.imgUrl, // imgUrl é opcional
  });

  // Converte o modelo para um mapa que pode ser enviado para o Firestore
  Map<String, dynamic> toMap([String? imageUrl]) {
    return {
      'cliente': cliente,
      'nome': nome,
      'raca': raca,
      'especie': especie,
      'idade': idade,
      'genero': genero,
      'peso': peso,
      'alergias': alergias,
      'emTratamento': emTratamento,
      'imgUrl': imageUrl ??
          imgUrl, // Usa a imageUrl se fornecida, senão o imgUrl atual
    };
  }

  // Constrói um modelo a partir de um mapa
  factory PetModel.fromMap(Map<String, dynamic> map) {
    return PetModel(
      cliente: map['cliente'],
      nome: map['nome'],
      raca: map['raca'],
      especie: map['especie'],
      idade: map['idade'],
      peso: map['peso'],
      genero: map['genero'],
      alergias: map['alergias'],
      emTratamento: map['emTratamento'],
      imgUrl: map['imgUrl'],
    );
  }

  // Converte o modelo para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente': cliente,
      'nome': nome,
      'raca': raca,
      'especie': especie,
      'idade': idade,
      'genero': genero,
      'peso': peso,
      'alergias': alergias,
      'emTratamento': emTratamento,
      'imgUrl': imgUrl,
    };
  }

  // Constrói um modelo a partir de um documento do Firestore
  factory PetModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PetModel(
      id: doc.id,
      cliente: data['cliente'],
      nome: data['nome'],
      raca: data['raca'],
      especie: data['especie'],
      idade: data['idade'],
      genero: data['genero'],
      peso: data['peso'],
      alergias: data['alergias'],
      emTratamento: data['emTratamento'],
      imgUrl: data['imgUrl'],
    );
  }
}
