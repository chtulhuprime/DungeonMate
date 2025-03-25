import 'package:dungeon_mate/screens/PlayerScreens/player_home_screen.dart';
import 'package:dungeon_mate/widget/admin.dart';
import 'package:flutter/material.dart';

import 'MasterScreens/master_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Заголовок
            const Text(
              'Добро пожаловать в DungeonMate!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Подзаголовок
            const Text(
              'Пожалуйста, выберите вашу роль:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Кнопка Мастера
            ElevatedButton.icon(
              icon: const Icon(Icons.castle, size: 30),
              label: const Text(
                'Мастер',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _navigateToMaster(context, isMaster: true),
            ),
            const SizedBox(height: 20),

            // Кнопка Игрока
            ElevatedButton.icon(
              icon: const Icon(Icons.person, size: 30),
              label: const Text(
                'Игрок',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _navigateToPlayer(context, isPlayer: false),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.castle, size: 30),
              label: const Text(
                'Админ',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _navigateToAdmin(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _navigateToPlayer(BuildContext context, {required bool isPlayer}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PlayerHomeScreen(
              isPlayer: isPlayer,
              characters: [
              ], // Передаем пустой список или существующий список персонажей
            ),
      ),
    );
  }
}

void _navigateToAdmin(BuildContext context,) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) =>
          AdminScreen(),
    ),
  );
}

void _navigateToMaster(BuildContext context, {required bool isMaster}) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => MasterHomeScreen(isMaster: isMaster),
    ),
  );
}

