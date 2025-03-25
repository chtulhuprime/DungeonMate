import 'package:flutter/material.dart';
import '../../widget/spell.dart';

class SpellDetailsScreen extends StatelessWidget {
  final Spell spell;

  const SpellDetailsScreen({super.key, required this.spell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(spell.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  spell.imageUrl,
                  width: 150,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.shield, size: 100);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Описание:', style: Theme.of(context).textTheme.titleLarge),
            Text(spell.fullDescription),
            const SizedBox(height: 20),
            Text('Характеристики:', style: Theme.of(context).textTheme.titleLarge),
            ...spell.characteristics.entries.map((e) =>
                Text('${e.key}: ${e.value}')).toList(),
          ],
        ),
      ),
    );
  }
}