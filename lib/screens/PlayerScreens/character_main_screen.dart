import 'package:flutter/material.dart';
import '../../models/character.dart';
import 'inventory_screen.dart';
import 'spells_screen.dart';
import 'dice_roll_screen.dart';
import 'interactive_map_screen.dart';

class CharacterDetailsScreen extends StatefulWidget {
  final Character character;

  const CharacterDetailsScreen({super.key, required this.character});

  @override
  State<CharacterDetailsScreen> createState() => _CharacterDetailsScreenState();
}

class _CharacterDetailsScreenState extends State<CharacterDetailsScreen> {
  int _selectedIndex = 0; // Индекс выбранной вкладки

  // Список экранов для навигации
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    // Инициализируем экраны
    _screens.addAll([
      InventoryScreen(character: widget.character),
      SpellScreen(character: widget.character),
      DiceRollScreen(character: widget.character),
      InteractiveMapScreen(character: widget.character),
    ]);
  }

  // Обработка нажатия на иконку в BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300), // Длительность анимации
        transitionBuilder: (Widget child, Animation<double> animation) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
        child: _screens[_selectedIndex], // Отображаем выбранный экран
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Фиксированный стиль
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.backpack),
            label: 'Инвентарь',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'Заклинания',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: 'Кубик',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Карта',
          ),
        ],
      ),
    );
  }
}