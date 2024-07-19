import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petshopapp/models/pet_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CreatePetScreen extends StatefulWidget {
  final String userId;

  CreatePetScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CreatePetScreenState createState() => _CreatePetScreenState();
}

class _CreatePetScreenState extends State<CreatePetScreen> {
  PageController _pageController = PageController();
  TextEditingController nomeController = TextEditingController();
  TextEditingController pesoController = TextEditingController();

  String? selectedIdade;
  String? selectedRaca;
  String? selectedTipo;
  String? selectedGenero;
  String? selectedAlergia;
  bool hasAlergia = false;
  bool emTratamento = false;

  File? _imageFile; // Variável para armazenar a imagem selecionada

  final ImagePicker _picker = ImagePicker();

  final Map<String, List<String>> tipoParaRacas = {
    'Cachorro': ['Labrador', 'Poodle', 'Bulldog', 'Beagle', 'Outro'],
    'Gato': ['Siamês', 'Persa', 'Maine Coon', 'Outro'],
    'Pássaro': ['Canário', 'Periquito', 'Papagaio', 'Outro'],
    'Outro': ['Outro']
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Pet'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6141AC), Color(0xFFB487FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildFirstPage(),
            _buildSecondPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPageIndicator(1, "Preencha os dados do seu pet"),
            const SizedBox(height: 20),
            _buildTextField('Nome', nomeController),
            _buildDropdown('Idade (em anos)', selectedIdade, (value) {
              setState(() {
                selectedIdade = value;
              });
            }, ["1", "2", "3", "4"]),
            _buildDropdown('Tipo', selectedTipo, (value) {
              setState(() {
                selectedTipo = value;
                selectedRaca = null;
              });
            }, tipoParaRacas.keys.toList()),
            if (selectedTipo != null)
              _buildDropdown('Raça', selectedRaca, (value) {
                setState(() {
                  selectedRaca = value;
                });
              }, tipoParaRacas[selectedTipo] ?? []),
            const SizedBox(height: 20),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPageIndicator(2, "Detalhes adicionais do seu pet"),
            const SizedBox(height: 20),
            _buildTextField('Peso', pesoController,
                keyboardType: TextInputType.number),
            _buildDropdown('Gênero', selectedGenero, (value) {
              setState(() {
                selectedGenero = value;
              });
            }, ['Macho', 'Fêmea']),
            _buildAlergiasDropdown(),
            if (hasAlergia) _buildCheckbox('Em Tratamento'),
            const SizedBox(height: 20),
            _buildAddButton(),
            const SizedBox(height: 20),
            _buildSelectImageButton(), // Adiciona o botão para selecionar imagem
            _buildPreviewImage(), // Mostra a pré-visualização da imagem selecionada
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int currentPage, String pageText) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              currentPage == 1 ? Icons.filter_1 : Icons.check_circle,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(width: 5),
            Text(
              "Página $currentPage de 2",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(width: 5),
            Icon(
              currentPage == 2 ? Icons.filter_2 : Icons.check_circle_outline,
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          pageText,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          hintText: label,
          hintStyle: TextStyle(color: Colors.white38),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDropdown(String label, String? selectedValue,
      Function(String?) onChanged, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        style: TextStyle(color: Colors.white),
        dropdownColor: Color(0xFF6141AC),
      ),
    );
  }

  Widget _buildAlergiasDropdown() {
    return _buildDropdown('Alergias', selectedAlergia, (String? newValue) {
      setState(() {
        selectedAlergia = newValue;
        hasAlergia = newValue != 'Nenhuma';
      });
    }, ['Nenhuma', 'Pólen', 'Comida', 'Outros']);
  }

  Widget _buildCheckbox(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: emTratamento,
            onChanged: (bool? value) {
              setState(() {
                emTratamento = value ?? false;
              });
            },
            activeColor: Colors.white,
            checkColor: Color(0xFF6141AC),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
        ),
        onPressed: () {
          _pageController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        },
        child: const Text(
          'Próximo',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xFF6141AC),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          _adicionarPet();
        },
        child: const Text(
          'Adicionar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSelectImageButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xFF6141AC),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          _pickImage();
        },
        icon: Icon(Icons.camera_alt, color: Color(0xFF6141AC)),
        label: Text(
          'Selecionar Imagem',
          style: TextStyle(color: Color(0xFF6141AC)),
        ),
      ),
    );
  }

  Widget _buildPreviewImage() {
    return _imageFile == null
        ? SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: FileImage(_imageFile!),
            ),
          );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    try {
      // Acessa o Firebase Storage
      final firebase_storage.Reference storageRef =
          firebase_storage.FirebaseStorage.instance.ref().child('pets');

      // Gera um nome único para a imagem
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Faz o upload da imagem para o Firebase Storage
      await storageRef.child(fileName).putFile(imageFile);

      // Obtém a URL da imagem após o upload
      String imageUrl = await storageRef.child(fileName).getDownloadURL();

      return imageUrl;
    } catch (e) {
      // Em caso de erro, exibe uma mensagem ou realiza outra ação
      print('Erro ao fazer upload da imagem: $e');
      throw Exception('Erro ao fazer upload da imagem.');
    }
  }

  void _adicionarPet() async {
    final pet = PetModel(
      cliente: widget.userId,
      nome: nomeController.text,
      raca: selectedRaca!,
      idade: selectedIdade!,
      especie: selectedTipo!,
      peso: double.tryParse(pesoController.text) ?? 0.0,
      genero: selectedGenero!,
      alergias: selectedAlergia!,
      emTratamento: emTratamento,
    );

    try {
      // Upload da imagem (se houver)
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImageToStorage(_imageFile!);
      }

      // Adicionar pet ao Firestore
      await FirebaseFirestore.instance
          .collection('pets')
          .add(pet.toMap(imageUrl)); // Passa a URL da imagem aqui

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pet adicionado com sucesso!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar pet.')),
      );
    }
  }
}
