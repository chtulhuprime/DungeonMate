// lib/widgets/character_card.dart
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../screens/PlayerScreens/inventory_screen.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(character.name),
        subtitle: Text('${character.race} - ${character.characterClass}'),
        trailing: Text('Lvl ${character.level}'),
         onTap: () => Navigator.push(
           context,
           MaterialPageRoute(builder: (_) => InventoryScreen(character: character)),
        ),
        onLongPress: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: Text("Выберите действие"),
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, true);
                      onDelete();
                    },
                    child: const Text("Удалить персонажа"),
                  ),
                  SimpleDialogOption(
                    onPressed: (){
                      Navigator.pop(context, true);
                    },
                    child: const Text("Отмена"),
                  )
                ],
              );
            })
      ),
    );
  }
}