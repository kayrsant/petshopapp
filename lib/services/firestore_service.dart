import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petshopapp/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> salvarUsuario(UsuarioModel usuario) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuario.id)
          .set(usuario.toMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
