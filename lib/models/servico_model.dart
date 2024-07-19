class ServicoModel {
  final String id;
  final String? nome;
  final String? descricao;
  final double preco;

  ServicoModel({
    required this.id,
    this.nome,
    this.descricao,
    required this.preco,
  });

  factory ServicoModel.fromJson(Map<String, dynamic> json) {
    return ServicoModel(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      preco: json['preco'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
    };
  }
}
