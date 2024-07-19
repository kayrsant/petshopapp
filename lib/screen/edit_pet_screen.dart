import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petshopapp/models/pet_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshopapp/persistence/PetPersistence.dart';

class EditPetScreen extends StatefulWidget {
  final PetModel pet;

  const EditPetScreen({Key? key, required this.pet}) : super(key: key);

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alergiasController = TextEditingController();
  bool _emTratamento = false;

  File? _imageFile;
  String? _selectedIdade;
  String? _selectedGenero;

  List<String> _idades = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  List<String> _generos = ['Macho', 'Fêmea'];

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  void _loadPetData() {
    _nomeController.text = widget.pet.nome ?? '';
    _selectedIdade = widget.pet.idade;
    _selectedGenero = widget.pet.genero;
    _pesoController.text = widget.pet.peso?.toString() ?? '';
    _alergiasController.text = widget.pet.alergias ?? '';
    _emTratamento = widget.pet.emTratamento ?? false;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final ref = FirebaseStorage.instance.ref().child('pets/$fileName');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<void> _savePet() async {
    if (widget.pet.id == null || widget.pet.id!.isEmpty) {
      print('ID do pet é nulo ou vazio.');
      return;
    }

    PetModel updatedPet = PetModel(
      id: widget.pet.id,
      cliente: widget.pet.cliente,
      nome: _nomeController.text,
      raca: widget.pet.raca!, // Mantém a raça original
      especie: widget.pet.especie!, // Mantém a espécie original
      idade: _selectedIdade!,
      genero: _selectedGenero!,
      peso: double.tryParse(_pesoController.text) ?? 0.0,
      alergias: _alergiasController.text,
      emTratamento: _emTratamento,
      imgUrl: _imageFile != null
          ? await _uploadImage(_imageFile!)
          : widget.pet.imgUrl,
    );

    try {
      PetPersistence persistence = PetPersistence();
      await persistence.atualizar(updatedPet);

      Navigator.pop(context, true); // Indica que o pet foi atualizado
    } catch (e) {
      print('Erro ao atualizar pet: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text('Erro ao atualizar o pet. Detalhes: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _deletePet() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('pets').doc(widget.pet.id).delete();

      Navigator.pop(context, true); // Indica que o pet foi deletado
    } catch (e) {
      print('Erro ao deletar pet: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text('Erro ao deletar o pet. Detalhes: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Pet'),
        actions: [
          IconButton(
            onPressed: _savePet,
            icon: Icon(Icons.save),
          ),
          IconButton(
            onPressed: _deletePet,
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imageFile == null
                    ? widget.pet.imgUrl != null
                        ? Image.network(
                            widget.pet.imgUrl!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                          )
                    : Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedIdade,
              items: _idades.map((idade) {
                return DropdownMenuItem<String>(
                  value: idade,
                  child: Text(idade),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIdade = value;
                });
              },
              decoration: InputDecoration(labelText: 'Idade'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGenero,
              items: _generos.map((genero) {
                return DropdownMenuItem<String>(
                  value: genero,
                  child: Text(genero),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGenero = value;
                });
              },
              decoration: InputDecoration(labelText: 'Gênero'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _pesoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Peso'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _alergiasController,
              decoration: InputDecoration(labelText: 'Alergias'),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Em Tratamento'),
              value: _emTratamento,
              onChanged: (value) {
                setState(() {
                  _emTratamento = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
