import 'package:flutter/material.dart';
import 'package:petshopapp/models/pet_model.dart';
import 'package:petshopapp/screen/edit_pet_screen.dart';

class PetCard extends StatelessWidget {
  final PetModel pet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  PetCard({
    required this.pet,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: pet.imgUrl != null
            ? Image.network(pet.imgUrl!)
            : Icon(Icons.pets, size: 40),
        title: Text(
          pet.nome ?? 'Nome não informado',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${pet.idade ?? ''} anos | ${pet.genero ?? ''}'),
            Text('${pet.raca ?? ''} | ${pet.especie ?? ''}'),
            if (pet.alergias != null && pet.alergias != 'Nenhuma')
              Text('Alergias: ${pet.alergias}'),
            if (pet.emTratamento == true)
              Text('Em tratamento', style: TextStyle(color: Colors.red)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
