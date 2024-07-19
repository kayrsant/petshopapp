class UsuarioModel {
  String id;
  String nome;
  String email;
  String senha;
  String token;

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'token': token,
    };
  }
}
