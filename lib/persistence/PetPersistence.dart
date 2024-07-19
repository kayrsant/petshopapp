import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshopapp/models/pet_model.dart';

class PetPersistence {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _petsCollection =
      FirebaseFirestore.instance.collection('pets');

  Future<bool> salvar(PetModel pet) async {
    try {
      await _petsCollection.doc(pet.id).set(pet.toJson());
      return true;
    } catch (e) {
      print('Erro ao salvar pet: $e');
      return false;
    }
  }

  Future<List<PetModel>> listarPorCliente(String clienteId) async {
    try {
      QuerySnapshot snapshot =
          await _petsCollection.where('cliente', isEqualTo: clienteId).get();
      return snapshot.docs.map((doc) => PetModel.fromDocument(doc)).toList();
    } catch (e) {
      print('Erro ao listar pets: $e');
      return [];
    }
  }

  Future<PetModel?> buscarPorId(String id) async {
    try {
      DocumentSnapshot doc = await _petsCollection.doc(id).get();
      if (doc.exists) {
        return PetModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar pet por ID: $e');
      return null;
    }
  }

  Future<void> atualizar(PetModel pet) async {
    if (pet.id == null) {
      throw Exception('ID do pet não pode ser nulo.');
    }

    try {
      await _firestore.collection('pets').doc(pet.id).update({
        'nome': pet.nome,
        'raca': pet.raca,
        'especie': pet.especie,
        'idade': pet.idade,
        'genero': pet.genero,
        'peso': pet.peso,
        'alergias': pet.alergias,
        'emTratamento': pet.emTratamento,
        'imgUrl': pet.imgUrl,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar pet: $e');
    }
  }

  Future<void> deletar(String petId) async {
    try {
      await _petsCollection.doc(petId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar pet: $e');
    }
  }
}
