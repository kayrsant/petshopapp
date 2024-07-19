class FuncionarioModel {
  final String id;
  final String? nome;
  final String? email;
  final String? telefone;

  FuncionarioModel({
    required this.id,
    this.nome,
    this.email,
    this.telefone,
  });

  factory FuncionarioModel.fromJson(Map<String, dynamic> json) {
    return FuncionarioModel(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
    };
  }
}
