import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petshopapp/models/agendamento_model.dart';
import 'package:petshopapp/persistence/AgendamentoPersistence.dart';
import 'package:intl/intl.dart';
import 'package:petshopapp/screen/edit_agendamento_screen.dart';

class ListAgendamentosScreen extends StatefulWidget {
  final String userId;

  const ListAgendamentosScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _ListAgendamentosScreenState createState() => _ListAgendamentosScreenState();
}

class _ListAgendamentosScreenState extends State<ListAgendamentosScreen> {
  Map<String, String>? _servicos;
  Map<String, String>? _funcionarios;
  Map<String, String>? _pets;
  List<AgendamentoModel>? _agendamentos;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    print("UsuárioID: ${widget.userId}");
    try {
      final usuarioId = widget.userId;
      final relacionamentos = await _obterRelacionamentos(usuarioId);
      final agendamentos = await _listarAgendamentos(usuarioId);

      print("Relacionamentos: $relacionamentos"); // Debugging line
      print("Agendamentos: $agendamentos"); // Debugging line

      // Ordenar os agendamentos por data mais próxima
      agendamentos.sort((a, b) {
        final dataHoraA = a.dataHora?.toDate() ?? DateTime.now();
        final dataHoraB = b.dataHora?.toDate() ?? DateTime.now();
        return dataHoraA.compareTo(dataHoraB);
      });

      setState(() {
        _servicos = relacionamentos['servicos'] as Map<String, String>?;
        _funcionarios = relacionamentos['funcionarios'] as Map<String, String>?;
        _pets = relacionamentos['pets'] as Map<String, String>?;
        _agendamentos = agendamentos;
      });
    } catch (error) {
      print('Erro ao carregar dados: $error');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: Text('Erro ao carregar dados: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<Map<String, String>> _obterPetsDoUsuario(String usuarioId) async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore
        .collection('pets')
        .where('cliente', isEqualTo: usuarioId)
        .get();

    print("USUARIOID: ${usuarioId}");
    final petsMap = <String, String>{};
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final id = data['id'] as String?;
      final nome = data['nome'] as String?;
      if (id != null && nome != null) {
        petsMap[id] = nome;
      }
    }

    return petsMap;
  }

  Future<Map<String, Map<String, String>>> _obterRelacionamentos(
      String usuarioId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Obter serviços
      final servicosSnapshot = await firestore.collection('servicos').get();
      final servicoMap = <String, String>{};
      for (var doc in servicosSnapshot.docs) {
        final data = doc.data();
        final id = data['id'];
        final nome = data['nome'];
        if (id != null && nome != null) {
          servicoMap[id] = nome;
        }
      }
      print('Serviços carregados: $servicoMap');

      // Obter funcionários
      final funcionariosSnapshot =
          await firestore.collection('funcionarios').get();
      final funcionarioMap = <String, String>{};
      for (var doc in funcionariosSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final id = data['id'] as String?;
        final nome = data['nome'] as String?;
        if (id != null && nome != null) {
          funcionarioMap[id] = nome;
        }
      }
      print('Funcionários carregados: $funcionarioMap');

      // Obter pets
      final petsMap = await _obterPetsDoUsuario(usuarioId);
      print('Pets carregados: $petsMap');

      return {
        'servicos': servicoMap,
        'funcionarios': funcionarioMap,
        'pets': petsMap,
      };
    } catch (e) {
      print('Erro ao obter relacionamentos: $e');
      return {
        'servicos': {},
        'funcionarios': {},
        'pets': {},
      };
    }
  }

  Future<List<AgendamentoModel>> _listarAgendamentos(String usuarioId) async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore
        .collection('agendamentos')
        .where('clienteId', isEqualTo: usuarioId)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return AgendamentoModel(
        id: doc.id,
        clienteId: data['clienteId'],
        pet: data['pet'],
        dataHora: data['dataHora'],
        servicos: data['servicos'],
        funcionario: data['funcionario'],
        valor: (data['valor'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  Future<void> _editAgendamento(AgendamentoModel agendamento) async {
    bool? agendamentoAtualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAgendamentoScreen(agendamento: agendamento),
      ),
    );

    if (agendamentoAtualizado == true) {
      // Recarregar os agendamentos
      final agendamentosAtualizados = await _listarAgendamentos(widget.userId);
      setState(() {
        _agendamentos = agendamentosAtualizados;
      });
    }
  }

  Future<void> _deleteAgendamento(String id) async {
    final agendamentoPersistence = AgendamentoPersistence();
    await agendamentoPersistence.remover(id);

    // Recarregar os agendamentos após a exclusão
    final agendamentosAtualizados = await _listarAgendamentos(widget.userId);
    setState(() {
      _agendamentos = agendamentosAtualizados;
    });
  }

  Future<void> _refreshData() async {
    await _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        titleTextStyle: const TextStyle(
          color: Colors.deepPurple,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _servicos == null ||
                _funcionarios == null ||
                _pets == null ||
                _agendamentos == null
            ? const Center(child: CircularProgressIndicator())
            : _agendamentos!.isEmpty
                ? Center(
                    child: Text(
                      'Não há agendamentos',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _agendamentos!.length,
                    itemBuilder: (context, index) {
                      final agendamento = _agendamentos![index];
                      // Adicionar verificação para garantir que servicos não é nulo
                      final servicoIds = agendamento.servicos?.split(',') ?? [];

                      // Usar map para processar os IDs de serviço
                      final servicoNome = servicoIds
                          .map((id) => _servicos?[id] ?? 'Desconhecido')
                          .join(', ');

                      final funcionarioNome =
                          _funcionarios?[agendamento.funcionario ?? ''] ??
                              'Desconhecido'; // Protege contra nulos
                      final petNome = _pets?[agendamento.pet ?? ''] ??
                          'Desconhecido'; // Protege contra nulos

                      final dataHora =
                          (agendamento.dataHora as Timestamp).toDate();

                      final dataFormatada =
                          DateFormat('dd/MM/yyyy HH:mm').format(dataHora);

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        elevation: 5,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            'Pet: $petNome',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data: $dataFormatada',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Funcionário: $funcionarioNome',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Serviços: $servicoNome',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Valor: R\$ ${agendamento.valor.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editAgendamento(agendamento),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Excluir Agendamento'),
                                      content: const Text(
                                          'Tem certeza de que deseja excluir este agendamento?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _deleteAgendamento(
                                                agendamento.id! as String);
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Excluir'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
