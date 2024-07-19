import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshopapp/models/user_model.dart';
import 'package:petshopapp/screen/create_agendamento_screen.dart';
import 'package:petshopapp/screen/list_pet_screen.dart';
import 'package:petshopapp/screen/create_pet_screen.dart';
import 'package:petshopapp/screen/list_agendamentos_screen.dart';
import 'package:petshopapp/screen/login_screen.dart';

class PostLoginScreen extends StatefulWidget {
  final String userEmail;

  const PostLoginScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _PostLoginScreenState createState() => _PostLoginScreenState();
}

class _PostLoginScreenState extends State<PostLoginScreen> {
  String? userName;
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          userName = user.displayName ?? "Usuário";
          userId = user.uid;
        });
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print("Erro ao buscar usuário: $e");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: userName != null
            ? Text('Bem-vindo, $userName')
            : const Text('Bem-vindo'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _signOut();
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height -
            kToolbarHeight -
            kBottomNavigationBarHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6141AC), Color(0xFFB487FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionCard(
                  context,
                  'Agendamentos',
                  Icons.schedule,
                  Colors.blue,
                  [
                    _buildCardButton(
                      context,
                      'Agendar Serviço',
                      Icons.add,
                      Colors.blue,
                      userId != null
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateAgendamentoScreen(
                                    usuarioLogadoId: userId!,
                                  ),
                                ),
                              )
                          : null,
                    ),
                    _buildCardButton(
                      context,
                      'Ver Agendamentos',
                      Icons.view_list,
                      Colors.orange,
                      userId != null
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ListAgendamentosScreen(
                                            userId: userId!)),
                              )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildSectionCard(
                  context,
                  'Pets',
                  Icons.pets,
                  Colors.green,
                  [
                    _buildCardButton(
                      context,
                      'Adicionar Pet',
                      Icons.add,
                      Colors.green,
                      userId != null
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CreatePetScreen(userId: userId!),
                                ),
                              )
                          : null,
                    ),
                    _buildCardButton(
                      context,
                      'Listar Pets',
                      Icons.list,
                      Colors.purple,
                      userId != null
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ListPetsScreen(userId: userId!),
                                ),
                              )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets, color: Colors.deepPurple),
            label: 'Pets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule, color: Colors.deepPurple),
            label: 'Agendamentos',
          ),
        ],
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) {
          if (index == 0 && userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListPetsScreen(userId: userId!),
              ),
            );
          } else if (index == 1 && userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListAgendamentosScreen(userId: userId!),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color cardColor,
    List<Widget> buttons,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: cardColor,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...buttons,
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton(
    BuildContext context,
    String label,
    IconData icon,
    Color iconColor,
    VoidCallback? onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor),
        label: Text(
          label,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: iconColor),
        ),
      ),
    );
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Erro ao deslogar: $e");
    }
  }
}
