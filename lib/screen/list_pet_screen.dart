import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshopapp/models/pet_model.dart';
import 'package:petshopapp/screen/edit_pet_screen.dart';
import 'package:petshopapp/screen/pet_card.dart';

class ListPetsScreen extends StatefulWidget {
  final String userId;

  ListPetsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ListPetsScreenState createState() => _ListPetsScreenState();
}

class _ListPetsScreenState extends State<ListPetsScreen> {
  Future<void> _refreshPetList() async {
    setState(() {
      // Força a atualização da lista
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pets'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPetList,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pets')
              .where('cliente', isEqualTo: widget.userId)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Nenhum pet encontrado.'));
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                PetModel pet =
                    PetModel.fromMap(document.data() as Map<String, dynamic>);

                return PetCard(
                  pet: pet,
                  onEdit: () async {
                    bool? updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPetScreen(pet: pet),
                      ),
                    );
                    if (updated == true) {
                      _refreshPetList();
                    }
                  },
                  onDelete: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('pets')
                          .doc(pet.id)
                          .delete();

                      _showSnackbar("Pet deletado com sucesso!");
                    } catch (e) {
                      _showSnackbar("Erro ao deletar pet!");
                      print("Erro ao deletar pet: $e");
                    }
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
