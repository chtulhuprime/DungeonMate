import 'package:flutter/material.dart';
import '../../models/character.dart';
import '../../models/characters.dart';
import '../../widget/character_card.dart';
import 'character_creation_screen.dart';
import 'character_main_screen.dart';
import '../home_screen.dart';
import 'skills_screen.dart';

class PlayerHomeScreen extends StatefulWidget {
  final bool isPlayer;
  final List<Character> characters; // Добавляем параметр characters

  const PlayerHomeScreen({
    super.key,
    required this.isPlayer,
    required this.characters, // Принимаем список персонажей
  });

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  List<Character> characters = []; // Инициализируем пустым списком
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  // Загрузка персонажей из базы данных
  Future<void> _loadCharacters() async {
    final charactersFromDb = await _dbHelper.getCharacters();
    setState(() {
      characters = charactersFromDb;
    });
  }

  // Добавление персонажа
  void _addCharacter(Character newCharacter) async {
    await _dbHelper.insertCharacter(newCharacter);
    _loadCharacters(); // Обновляем список после добавления
  }

  // Удаление персонажа
  void _deleteCharacter(int index) async {
    final character = characters[index];
    await _dbHelper.deleteCharacter(character.id);
    _loadCharacters(); // Обновляем список после удаления
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String characterId, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить персонажа?'),
        content: const Text('Вы уверены, что хотите удалить этого персонажа?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Закрыть диалог
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              _deleteCharacter(index); // Удалить персонажа
              Navigator.pop(ctx); // Закрыть диалог
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPlayer ? 'Режим Игрока' : 'Мои Персонажи'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.ad_units),
            onPressed: () => _navigateToHome(context),
          )
        ],
      ),
      body: FutureBuilder<List<Character>>(
        future: _dbHelper.getCharacters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Персонажи не найдены'));
          } else {
            final characters = snapshot.data!;
            return ListView.builder(
              itemCount: characters.length,
              itemBuilder: (context, index) =>
                  ListTile(
                    title: Text(characters[index].name),
                    subtitle: Text(
                        '${characters[index].race} - ${characters[index]
                            .characterClass}'),
                    onTap: () {
                      // Переход на экран характеристик
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CharacterDetailsScreen(
                                  character: characters[index]),
                        ),
                      );
                    },
                    onLongPress: () {
                      // Показываем диалоговое окно для удаления
                      _showDeleteDialog(context, characters[index].id, index);
                    },
                  ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CharacterCreationScreen(
                      onSave: _addCharacter,
                      characters: characters,
                    ),
              ),
            ),
        child: const Icon(Icons.add),
      ),
    );
  }
}