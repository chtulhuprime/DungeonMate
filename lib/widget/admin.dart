import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/characters.dart';

class AdminScreen extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper();

  AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить предметы')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await dbHelper.insertSampleItems();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Предметы добавлены!')),
            );
          },
          child: const Text('Добавить тестовые предметы'),
        ),
      ),
    );
  }
}