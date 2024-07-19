import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petshopapp/models/agendamento_model.dart';
import 'package:petshopapp/persistence/ServicoPersistence.dart';
import 'package:petshopapp/persistence/FuncionarioPersistence.dart';
import 'package:petshopapp/persistence/PetPersistence.dart';
import 'package:petshopapp/persistence/AgendamentoPersistence.dart';
import 'package:intl/intl.dart';

class EditAgendamentoScreen extends StatefulWidget {
  final AgendamentoModel agendamento;

  const EditAgendamentoScreen({Key? key, required this.agendamento})
      : super(key: key);

  @override
  _EditAgendamentoScreenState createState() => _EditAgendamentoScreenState();
}

class _EditAgendamentoScreenState extends State<EditAgendamentoScreen> {
  late AgendamentoModel _agendamento;
  DateTime? _dataHora;
  List<String> _selectedServicos = [];
  String? _selectedFuncionario;
  String? _selectedPet;
  final _valorController = TextEditingController();

  Map<String, String>? _servicos;
  Map<String, String>? _funcionarios;
  Map<String, String>? _pets;
  Map<String, double>? _precosServicos; // Armazena os preços dos serviços

  @override
  void initState() {
    super.initState();
    _agendamento = widget.agendamento;
    _dataHora = _agendamento.dataHora?.toDate();
    _selectedServicos = (_agendamento.servicos ?? '').split(',').toList();
    _selectedFuncionario = _agendamento.funcionario;
    _selectedPet = _agendamento.pet;
    _valorController.text = _agendamento.valor.toStringAsFixed(2);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Carregar os serviços
      final servicoPersistence = ServicoPersistence();
      final servicos = await servicoPersistence.listar();
      setState(() {
        _servicos = {for (var s in servicos) s.id: s.nome ?? ''};
        _precosServicos = {
          for (var s in servicos) s.id: s.preco ?? 0.0
        }; // Carregar os preços dos serviços
      });

      // Carregar os funcionários
      final funcionarioPersistence = FuncionarioPersistence();
      final funcionarios = await funcionarioPersistence.listar();
      setState(() {
        _funcionarios = {for (var f in funcionarios) f.id: f.nome ?? ''};
      });

      // Carregar os pets para um cliente específico
      final petPersistence = PetPersistence();
      final pets =
          await petPersistence.listarPorCliente(_agendamento.clienteId!);
      setState(() {
        _pets = {
          for (var p in pets) p.id!: p.nome ?? ''
        }; // Garantir que IDs não sejam nulos
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

  void _updateValor(String? selectedServicoId) {
    if (selectedServicoId != null && _precosServicos != null) {
      final precoServico = _precosServicos![selectedServicoId] ?? 0.0;
      _valorController.text = precoServico.toStringAsFixed(2);
    }
  }

  Future<void> _saveChanges() async {
    try {
      final DateTime agendamentoDataHora = DateTime(
        _dataHora!.year,
        _dataHora!.month,
        _dataHora!.day,
        _dataHora!.hour,
        _dataHora!.minute,
      );

      final Timestamp agendamentoTimestamp =
          Timestamp.fromDate(agendamentoDataHora);

      final agendamento = AgendamentoModel(
        id: _agendamento.id,
        clienteId: _agendamento.clienteId,
        pet: _selectedPet!,
        dataHora: agendamentoTimestamp,
        servicos: _selectedServicos.join(','),
        funcionario: _selectedFuncionario!,
        valor: double.parse(_valorController.text),
      );

      final agendamentoPersistence = AgendamentoPersistence();
      await agendamentoPersistence.editar(agendamento);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento atualizado com sucesso!')),
      );

      Navigator.pop(context, true); // Retorna verdadeiro para indicar sucesso
    } catch (error) {
      print('Erro ao salvar mudanças: $error');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: Text('Erro ao salvar mudanças: $error'),
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

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final String formattedDate = dateFormat.format(_dataHora!);
    final TimeOfDay timeOfDay = TimeOfDay.fromDateTime(_dataHora!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Agendamento'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Pet: ${_pets?[_selectedPet ?? ''] ?? 'Desconhecido'}'),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value:
                    _selectedServicos.isNotEmpty ? _selectedServicos[0] : null,
                items: _servicos?.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      _selectedServicos = [value];
                      _updateValor(
                          value); // Atualizar valor ao selecionar serviço
                    }
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Selecione o Serviço',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedFuncionario,
                items: _funcionarios?.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFuncionario = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Selecione o Funcionário',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title:
                    Text('Data: $formattedDate ${timeOfDay.format(context)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dataHora!,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: timeOfDay,
                    );

                    if (pickedTime != null) {
                      setState(() {
                        _dataHora = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o valor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedPet != null &&
                      _selectedServicos.isNotEmpty &&
                      _selectedFuncionario != null &&
                      _dataHora != null &&
                      _valorController.text.isNotEmpty) {
                    await _saveChanges();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preencha todos os campos'),
                      ),
                    );
                  }
                },
                child: const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
