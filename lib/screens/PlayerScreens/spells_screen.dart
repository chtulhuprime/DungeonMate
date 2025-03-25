import 'package:dungeon_mate/widget/spell_card.dart';
import 'package:dungeon_mate/widget/spell_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/character.dart';

class SpellScreen extends StatefulWidget {
  final Character character;

  const SpellScreen({super.key, required this.character});

  @override
  State<SpellScreen> createState() => _SpellScreenState();
}

class _SpellScreenState extends State<SpellScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SpellProvider>(context, listen: false);
    provider.selectCharacter(widget.character);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заклинания ${widget.character.name}'),
      ),
      body: Consumer<SpellProvider>(
        builder: (context, provider, child) {
          if (provider.characterSpells.isEmpty) {
            return const Center(child: Text('Нет известных заклинаний'));
          }

          return ListView.builder(
            itemCount: provider.characterSpells.length,
            itemBuilder: (context, index) {
              final spell = provider.characterSpells[index];
              return SpellCard(spell: spell);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final provider = Provider.of<SpellProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить заклинание в книгу'),
          content: FutureBuilder(
            future: provider.loadAllSpells(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.spells.length,
                  itemBuilder: (context, index) {
                    final spell = provider.spells[index];
                    return ListTile(
                      title: Text(spell.name),
                      subtitle: Text(spell.description),
                      onTap: () {
                        provider.addSpellToCharacter(spell);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ],
        );
      },
    );
  }
}