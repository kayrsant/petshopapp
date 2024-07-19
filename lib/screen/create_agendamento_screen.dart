import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshopapp/models/agendamento_model.dart';
import 'package:petshopapp/models/funcionario_model.dart';
import 'package:petshopapp/models/pet_model.dart';
import 'package:petshopapp/models/servico_model.dart';

class CreateAgendamentoScreen extends StatefulWidget {
  final String? usuarioLogadoId;

  const CreateAgendamentoScreen({Key? key, required this.usuarioLogadoId})
      : super(key: key);

  @override
  _CreateAgendamentoScreenState createState() =>
      _CreateAgendamentoScreenState();
}

class _CreateAgendamentoScreenState extends State<CreateAgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPetId;
  DateTime _data = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();
  String? _selectedServicoId;
  String? _selectedFuncionarioId;
  late double _valor = 0.0;

  final TextEditingController _valorController = TextEditingController();

  List<PetModel> _pets = [];
  List<ServicoModel> _servicos = [];
  List<FuncionarioModel> _funcionarios = [];

  @override
  void initState() {
    super.initState();
    _loadPets();
    _loadServicos();
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _loadPets() async {
    try {
      print('Carregando pets...');
      final snapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('cliente', isEqualTo: widget.usuarioLogadoId)
          .get();

      print('ClientID: ${widget.usuarioLogadoId}');
      print('Pets snapshot size: ${snapshot.size}');
      if (snapshot.docs.isEmpty) {
        print('Nenhum pet encontrado');
      }

      setState(() {
        _pets = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          print('Pet data: $data');
          return PetModel(
              id: doc.id,
              cliente: data['cliente'],
              nome: data['nome'],
              especie: data['especie'],
              raca: data['raca'],
              idade: data['idade'],
              genero: data['genero'],
              peso: data['peso'],
              emTratamento: data['emTratamento']);
        }).toList();
        if (_pets.isNotEmpty) {
          _selectedPetId = _pets.first.id;
        }
      });
    } catch (e) {
      print('Error loading pets: $e');
    }
  }

  Future<void> _loadServicos() async {
    try {
      print('Carregando serviços...');
      final snapshot =
          await FirebaseFirestore.instance.collection('servicos').get();

      print('Serviços snapshot size: ${snapshot.size}');
      if (snapshot.docs.isEmpty) {
        print('Nenhum serviço encontrado');
      }

      setState(() {
        _servicos = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          print('Serviço data: $data');
          return ServicoModel(
            id: doc.id,
            nome: data['nome'],
            preco: (data['preco']).toDouble(),
          );
        }).toList();
        if (_servicos.isNotEmpty) {
          _selectedServicoId = _servicos.first.id;
          _valor = _servicos.first.preco;
          _valorController.text = _valor.toString();
          _loadFuncionarios();
        }
      });
    } catch (e) {
      print('Error loading services: $e');
    }
  }

  Future<void> _loadFuncionarios() async {
    if (_selectedServicoId == null) return;

    try {
      print('Carregando funcionários...');
      final snapshot =
          await FirebaseFirestore.instance.collection('funcionarios').get();

      setState(() {
        _funcionarios = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          print('Funcionário data: $data');
          return FuncionarioModel(
            id: doc.id,
            nome: data['nome'],
          );
        }).toList();
        if (_funcionarios.isNotEmpty) {
          _selectedFuncionarioId = _funcionarios.first.id;
        }
      });
    } catch (e) {
      print('Error loading employees: $e');
    }
  }

  void _onServicoChanged(String? value) {
    setState(() {
      _selectedServicoId = value;
      if (_selectedServicoId != null) {
        final servico = _servicos.firstWhere((s) => s.id == _selectedServicoId);
        _valor = servico.preco;
        _valorController.text = _valor.toString();
        print('valor setado em ${_valor}');
        _loadFuncionarios();
      } else {
        _valor = 0.0;
        _valorController.text = '0.0';
        _funcionarios = [];
      }
    });
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _data = pickedDate;
      });
    }
  }

  Future<void> _confirmAgendamento() async {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final String formattedDate = dateFormat.format(_data);
    final String formattedTime = _hora.format(context);
    final String? servicoNome =
        _servicos.firstWhere((s) => s.id == _selectedServicoId).nome;
    final String? funcionarioNome =
        _funcionarios.firstWhere((f) => f.id == _selectedFuncionarioId).nome;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Você tem certeza que deseja agendar $servicoNome com $funcionarioNome às $formattedTime de $formattedDate?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _saveAgendamento();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAgendamento() async {
    final DateTime agendamentoDataHora = DateTime(
      _data.year,
      _data.month,
      _data.day,
      _hora.hour,
      _hora.minute,
    );

    final Timestamp agendamentoTimestamp =
        Timestamp.fromDate(agendamentoDataHora);

    final agendamento = AgendamentoModel(
      id: FirebaseFirestore.instance.collection('agendamentos').doc().id,
      clienteId: widget.usuarioLogadoId!,
      pet: _selectedPetId!,
      dataHora: agendamentoTimestamp,
      servicos: _selectedServicoId!,
      funcionario: _selectedFuncionarioId!,
      valor: _valor,
    );

    try {
      await FirebaseFirestore.instance
          .collection('agendamentos')
          .doc(agendamento.id)
          .set(agendamento.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento realizado com sucesso!')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error saving appointment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final String formattedDate = dateFormat.format(_data);
    final String formattedTime = _hora.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Agendamento'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedPetId,
                items: _pets.map((pet) {
                  return DropdownMenuItem<String>(
                    value: pet.id,
                    child: Text(pet.nome!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPetId = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Selecione o Pet',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Selecione um pet' : null,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedServicoId,
                items: _servicos.map((servico) {
                  return DropdownMenuItem<String>(
                    value: servico.id,
                    child: Text(servico.nome!),
                  );
                }).toList(),
                onChanged: _onServicoChanged,
                decoration: InputDecoration(
                  labelText: 'Selecione o Serviço',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Selecione um serviço' : null,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedFuncionarioId,
                items: _funcionarios.map((funcionario) {
                  return DropdownMenuItem<String>(
                    value: funcionario.id,
                    child: Text(funcionario.nome!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFuncionarioId = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Selecione o Funcionário',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Selecione um funcionário' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _valorController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: Text('Data: $formattedDate'),
                trailing: Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              ListTile(
                title: Text('Hora: $formattedTime'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _hora,
                  );

                  if (pickedTime != null && pickedTime != _hora) {
                    setState(() {
                      _hora = pickedTime;
                    });
                  }
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _confirmAgendamento();
                  }
                },
                child: const Text('Agendar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
