class FuncionarioServicoModel {
  final int funcionarioId;
  final int servicoId;

  FuncionarioServicoModel({required this.funcionarioId, required this.servicoId});

  Map<String, dynamic> toJson() {
    return {
      'funcionarioId': funcionarioId,
      'servicoId': servicoId,
    };
  }

  @override
  String toString() {
    return 'FuncionarioServicoModel(funcionarioId: $funcionarioId, servicoId: $servicoId)';
  }
}
