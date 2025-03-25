import 'package:dungeon_mate/screens/PlayerScreens/spell_detail_screen.dart';
import 'package:dungeon_mate/widget/spell.dart';
import 'package:dungeon_mate/widget/spell_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SpellCard extends StatelessWidget {
  final Spell spell;

  const SpellCard({super.key, required this.spell});

  @override
  Widget build(BuildContext context) {
    return Consumer<SpellProvider>(
      builder: (context, provider, child) {
        return Card(
          child: ListTile(
            leading: Image.asset(
              spell.imageUrl, // Вот здесь используется путь из вашего Item
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.shield); // Fallback иконка
              },
            ),
            title: Text(spell.name),
            subtitle: Text(spell.description),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpellDetailsScreen(spell: spell),
                ),
              );
            },
          ),
        );
      },
    );
  }
}