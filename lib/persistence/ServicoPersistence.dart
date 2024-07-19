import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshopapp/models/servico_model.dart';

class ServicoPersistence {
  final CollectionReference _servicesCollection =
      FirebaseFirestore.instance.collection('servicos');

  Future<bool> salvar(ServicoModel servico) async {
    try {
      print('Saving service: ${servico.toString()}');
      await _servicesCollection.doc(servico.id).set(servico.toJson());
      return true;
    } catch (e) {
      print('Error saving service: $e');
      return false;
    }
  }

  Future<List<ServicoModel>> listar() async {
    try {
      final QuerySnapshot querySnapshot = await _servicesCollection.get();
      print('Number of services: ${querySnapshot.docs.length}');

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ServicoModel(
          id: doc.id,
          nome: data['nome'],
          descricao: data['descricao'],
          preco: data['preco'].toDouble(),
        );
      }).toList();
    } catch (e) {
      print('Error listing services: $e');
      return [];
    }
  }

  Future<ServicoModel?> obter(String id) async {
    try {
      final DocumentSnapshot doc = await _servicesCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return ServicoModel(
          id: doc.id,
          nome: data['nome'],
          descricao: data['descricao'],
          preco: data['preco'].toDouble(),
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting service: $e');
      return null;
    }
  }

  Future<bool> remover(String id) async {
    try {
      await _servicesCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }

  Future<bool> editar(ServicoModel servico) async {
    try {
      await _servicesCollection.doc(servico.id).update(servico.toJson());
      return true;
    } catch (e) {
      print('Error editing service: $e');
      return false;
    }
  }

  Future<void> initializeDefaultServices() async {
    final List<Map<String, dynamic>> services = [
      {
        'nome': 'Banho Completo',
        'preco': 80.0,
      },
      {
        'nome': 'Corte de Unhas',
        'preco': 30.0,
      },
      {
        'nome': 'Higiene Dental',
        'descricao': 'Limpeza e manutenção da higiene dental dos pets',
        'preco': 50.0,
      },
    ];

    for (var service in services) {
      final docRef = _servicesCollection.doc();
      service['id'] = docRef.id;
      await docRef.set(service);
    }
  }
}
