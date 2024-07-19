import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshopapp/models/agendamento_model.dart';

class AgendamentoPersistence {
  final CollectionReference _agendamentosCollection =
      FirebaseFirestore.instance.collection('agendamentos');

  Future<void> salvar(AgendamentoModel agendamento) async {
    try {
      await _agendamentosCollection
          .doc(agendamento.id.toString())
          .set(agendamento.toMap());
    } catch (e) {
      print('Erro ao salvar agendamento: $e');
      throw Exception('Erro ao salvar agendamento');
    }
  }

  Future<List<AgendamentoModel>> listar() async {
    try {
      QuerySnapshot querySnapshot = await _agendamentosCollection.get();
      return querySnapshot.docs
          .map((doc) =>
              AgendamentoModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

  Future<List<AgendamentoModel>> listarPorCliente(String clienteId) async {
    try {
      QuerySnapshot querySnapshot = await _agendamentosCollection
          .where('clienteId', isEqualTo: clienteId)
          .get();
      return querySnapshot.docs
          .map((doc) =>
              AgendamentoModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching appointments by client: $e');
      return [];
    }
  }

  Future<AgendamentoModel?> buscarPorId(String id) async {
    try {
      DocumentSnapshot docSnapshot =
          await _agendamentosCollection.doc(id).get();
      if (docSnapshot.exists) {
        return AgendamentoModel.fromMap(
            docSnapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching appointment: $e');
      return null;
    }
  }

  Future<bool> editar(AgendamentoModel agendamento) async {
    try {
      if (agendamento.id != null) {
        await _agendamentosCollection
            .doc(agendamento.id as String?)
            .update(agendamento.toMap());
        return true;
      } else {
        print('Error: ID is null.');
        return false;
      }
    } catch (e) {
      print('Error editing appointment: $e');
      return false;
    }
  }

  Future<bool> remover(String id) async {
    try {
      await _agendamentosCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting appointment: $e');
      return false;
    }
  }
}
