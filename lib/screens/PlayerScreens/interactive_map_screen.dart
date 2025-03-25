import 'package:flutter/material.dart';
import '../../models/character.dart';

class InteractiveMapScreen extends StatelessWidget {
  final Character character;

  const InteractiveMapScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Интерактивная карта'),
      ),
      body: Center(
        child: Text('Интерактивная карта для персонажа ${character.name}'),
      ),
    );
  }
}