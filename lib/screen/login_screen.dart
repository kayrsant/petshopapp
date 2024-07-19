import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petshopapp/screen/create_account_screen.dart';
import 'package:petshopapp/screen/post_login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:petshopapp/services/crypto.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF6141AC),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'PetLife',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Seu Melhor PetShop!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                _buildEmailField(),
                const SizedBox(height: 15),
                _buildPasswordField(),
                const SizedBox(height: 30),
                _buildLoginButton(context),
                const SizedBox(height: 20),
                _buildCreateAccountButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        labelText: 'E-mail',
        labelStyle: TextStyle(color: Colors.white70),
        hintText: 'E-mail',
        hintStyle: TextStyle(color: Colors.white38),
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        labelText: 'Senha',
        labelStyle: TextStyle(color: Colors.white70),
        hintText: 'Senha',
        hintStyle: TextStyle(color: Colors.white38),
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
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
        onPressed: () async {
          try {
            String email = _emailController.text;
            String password = _passwordController.text;

            UserCredential userCredential = await FirebaseAuth.instance
                .signInWithEmailAndPassword(email: email, password: password);

            // Obtenha o usuário do Firestore
            DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(userCredential.user!.uid)
                .get();

            if (userSnapshot.exists) {
              String storedHashedPassword = userSnapshot['senha'];

              // Verifique a senha
              if (verifyPassword(password, storedHashedPassword)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostLoginScreen(
                      userEmail: email, // Passe o email do usuário
                    ),
                  ),
                );
              } else {
                _showSnackbar("Senha incorreta");
              }
            } else {
              _showSnackbar("Usuário não encontrado");
            }
          } catch (e) {
            _showSnackbar("Erro: ${e.toString()}");
          }
        },
        child: const Text(
          'Entrar',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6141AC)),
        ),
      ),
    );
  }

  Widget _buildCreateAccountButton(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateAccountScreen()),
          );
        },
        child: const Text(
          'Criar Conta',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
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
