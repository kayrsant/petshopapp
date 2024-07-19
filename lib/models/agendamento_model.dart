import 'package:cloud_firestore/cloud_firestore.dart';

class AgendamentoModel {
  final String? id;
  final String? clienteId;
  final String? pet;
  final String? funcionario;
  final String? servicos;
  final Timestamp? dataHora;
  final double valor;

  AgendamentoModel({
    this.id,
    required this.clienteId,
    required this.pet,
    required this.funcionario,
    required this.servicos,
    required this.dataHora,
    required this.valor,
  });

  factory AgendamentoModel.fromMap(Map<String, dynamic> map) {
    return AgendamentoModel(
      id: map['id'],
      clienteId: map['clienteId'],
      pet: map['pet'],
      funcionario: map['funcionario'],
      servicos: map['servicos'],
      dataHora: map['dataHora'],
      valor: map['valor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteId': clienteId,
      'pet': pet,
      'dataHora': dataHora,
      'servicos': servicos,
      'funcionario': funcionario,
      'valor': valor,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'pet': pet,
      'dataHora': dataHora,
      'servicos': servicos,
      'funcionario': funcionario,
      'valor': valor,
    };
  }

  factory AgendamentoModel.fromJson(Map<String, dynamic> json) {
    return AgendamentoModel(
      id: json['id'],
      clienteId: json['clienteId'],
      pet: json['pet'],
      funcionario: json['funcionario'],
      servicos: json['servicos'],
      dataHora: json['dataHora'],
      valor: (json['valor']).toDouble(),
    );
  }
}
