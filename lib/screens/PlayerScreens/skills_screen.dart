import 'package:flutter/material.dart';
import '../../models/character.dart';
import 'player_home_screen.dart';

class SkillsScreen extends StatefulWidget {
  final Character character;
  final Function(Character) onSave;
  final List<Character> characters; // Добавляем параметр characters

  const SkillsScreen({
    super.key,
    required this.character,
    required this.onSave,
    required this.characters, // Принимаем список персонажей
  });

  @override
  _SkillsScreenState createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final Map<String, bool> _selectedSkills = {};
  int _maxSkills = 2;

  final Map<String, List<String>> _classSkillRestrictions = {
    'Варвар': ['Атлетика', 'Восприятие', 'Выживание', 'Запугивание', 'Природа', 'Уход за животными'],
    'Бард': [], // Бард может выбирать любые умения
    // Добавьте другие классы и их ограничения
  };

  @override
  void initState() {
    super.initState();
    _initializeSelectedSkills();
    _setMaxSkills();
  }

  void _initializeSelectedSkills() {
    for (var skill in widget.character.proficientSkills) {
      _selectedSkills[skill] = true;
    }
  }

  void _setMaxSkills() {
    switch (widget.character.characterClass) {
      case 'Бард':
        _maxSkills = 3;
        break;
      case 'Варвар':
        _maxSkills = 2;
        break;
      default:
        _maxSkills = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final skills = {
      'Акробатика': widget.character.dexterity,
      'Анализ': widget.character.intelligence,
      'Атлетика': widget.character.strength,
      'Внимательность': widget.character.wisdom,
      'Выживание': widget.character.wisdom,
      'Запугивание': widget.character.charisma,
      'История': widget.character.intelligence,
      'Магия': widget.character.intelligence,
      'Медицина': widget.character.wisdom,
      'Обман': widget.character.charisma,
      'Природа': widget.character.intelligence,
      'Проницательность': widget.character.wisdom,
      'Религия': widget.character.intelligence,
      'Скрытность': widget.character.dexterity,
      'Убеждение': widget.character.charisma,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Умения персонажа'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSkills,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Отступы вокруг списка
        child: Column(
          children: [
            _buildSkillCounter(),
            _buildSkillList(skills), // Используем Wrap для отображения навыков
          ],
        ),
      ),
    );
  }

  Widget _buildSkillCounter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        'Выбрано умений: ${_selectedSkills.length}/$_maxSkills',
        style: TextStyle(
          fontSize: 14,
          color: _selectedSkills.length == _maxSkills ? Colors.green : Colors.black,
        ),
      ),
    );
  }

  Widget _buildSkillList(Map<String, int> skills) {
    final restrictedSkills = _classSkillRestrictions[widget.character.characterClass];

    return Wrap(
      spacing: 2, // Расстояние между элементами по горизонтали
      runSpacing: 2, // Расстояние между строками
      children: skills.entries.map((entry) {
        final skillName = entry.key;
        final skillValue = entry.value;
        final modifier = _calculateModifier(skillValue);

        final isSkillAvailable = restrictedSkills == null || restrictedSkills.isEmpty || restrictedSkills.contains(skillName);
        final isSelected = _selectedSkills[skillName] ?? false; // Проверяем, выбран ли навык

        return SizedBox(
          width: (MediaQuery.of(context).size.width - 34) / 2, // Ширина элемента (половина экрана минус отступы)
          child: Card(
            color: isSelected ? Colors.blue[100] : (isSkillAvailable ? null : Colors.grey[300]), // Подсветка выбранного навыка
            elevation: isSelected ? 4 : 2, // Увеличиваем тень для выбранного навыка
            shape: RoundedRectangleBorder(
              side: isSelected
                  ? const BorderSide(color: Colors.green, width: 2) // Граница для выбранного навыка
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.0), // Внутренние отступы карточки
              child: ListTile(
                title: Text(
                  skillName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Жирный шрифт для выбранного навыка
                  ),
                ),
                subtitle: Text(
                  'Модификатор: $modifier',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: isSkillAvailable ? () => _toggleSkillSelection(skillName) : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _toggleSkillSelection(String skillName) {
    setState(() {
      final restrictedSkills = _classSkillRestrictions[widget.character.characterClass];

      if (restrictedSkills != null && restrictedSkills.isNotEmpty && !restrictedSkills.contains(skillName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Для вашего класса доступны только: ${restrictedSkills.join(", ")}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedSkills[skillName] ?? false) {
        _selectedSkills.remove(skillName);
      } else {
        if (_selectedSkills.length < _maxSkills) {
          _selectedSkills[skillName] = true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Можно выбрать не более $_maxSkills умений'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void _saveSkills() {
    // Создаем обновленного персонажа с новыми умениями
    final updatedCharacter = widget.character.copyWith(
      proficientSkills: _selectedSkills.keys.toList(),
    );

    // Вызываем onSave с обновленным персонажем
    widget.onSave(updatedCharacter);

    // Переходим на экран PlayerHomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerHomeScreen(
          isPlayer: true, // или false, в зависимости от вашей логики
          characters: widget.characters, // Передаем обновленный список персонажей
        ),
      ),
    );
  }

  int _calculateModifier(int statValue) {
    return (statValue - 10) ~/ 2;
  }
}