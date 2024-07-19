import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshopapp/models/funcionario_model.dart';

class FuncionarioPersistence {
  final CollectionReference _funcionariosCollection =
      FirebaseFirestore.instance.collection('funcionarios');

  Future<bool> salvar(FuncionarioModel funcionario) async {
    try {
      print('Saving employee: ${funcionario.toString()}');
      await _funcionariosCollection
          .doc(funcionario.id)
          .set(funcionario.toJson());
      return true;
    } catch (e) {
      print('Error saving employee: $e');
      return false;
    }
  }

  Future<List<FuncionarioModel>> listar() async {
    try {
      final QuerySnapshot querySnapshot = await _funcionariosCollection.get();
      print('Number of employees: ${querySnapshot.docs.length}');

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FuncionarioModel(
          id: doc.id,
          nome: data['nome'],
          email: data['email'],
          // Adicione outros campos conforme necessário
        );
      }).toList();
    } catch (e) {
      print('Error listing employees: $e');
      return [];
    }
  }

  Future<FuncionarioModel?> obter(String id) async {
    try {
      final DocumentSnapshot doc = await _funcionariosCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return FuncionarioModel(
          id: doc.id,
          nome: data['nome'],
          email: data['email'],
          // Adicione outros campos conforme necessário
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting employee: $e');
      return null;
    }
  }

  Future<bool> remover(String id) async {
    try {
      await _funcionariosCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting employee: $e');
      return false;
    }
  }

  Future<bool> editar(FuncionarioModel funcionario) async {
    try {
      await _funcionariosCollection
          .doc(funcionario.id)
          .update(funcionario.toJson());
      return true;
    } catch (e) {
      print('Error editing employee: $e');
      return false;
    }
  }

  Future<void> initializeDefaultFuncionarios() async {
    final List<Map<String, dynamic>> funcionarios = [
      {
        'nome': 'João Silva',
        'email': 'joao.silva@example.com',
        // Adicione outros campos conforme necessário
      },
      {
        'nome': 'Maria Oliveira',
        'email': 'maria.oliveira@example.com',
        // Adicione outros campos conforme necessário
      },
      // Adicione mais funcionários conforme necessário
    ];

    for (var funcionario in funcionarios) {
      final docRef = _funcionariosCollection.doc();
      funcionario['id'] = docRef.id;
      await docRef.set(funcionario);
    }
  }
}
