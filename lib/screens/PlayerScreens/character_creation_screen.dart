import 'dart:math';

import 'package:flutter/material.dart';
import '../../models/character.dart';
import 'package:uuid/uuid.dart';

import 'player_home_screen.dart';
import 'skills_screen.dart';

var uuid = const Uuid();

class GeneratedStat {
  final int id;
  final int value;
  bool isUsed;

  GeneratedStat(this.id, this.value, {this.isUsed = false});
}

class CharacterCreationScreen extends StatefulWidget {
  final Function(Character) onSave;
  final List<Character> characters; // Добавляем параметр characters

  const CharacterCreationScreen({
    super.key,
    required this.onSave,
    required this.characters, // Принимаем список персонажей
  });

  @override
  State<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedRace;
  String? _selectedClass;
  int _level = 1;
  int _strength = 10;
  int _dexterity = 10;
  int _constitution = 10;
  int _intelligence = 10;
  int _wisdom = 10;
  int _charisma = 10;
  int _hitPoints = 10;
  String _background = '';

  String? _previousRace; // Для отслеживания предыдущей расы
  List<GeneratedStat>? _generatedStats;
  final List<String> _selectedHalfElfAbilities = [];
  bool _showAbilitySelection = false;
  bool _allStatsUsed = false;

  Map<String, bool> _isStatAssigned = {
    'Сила': false,
    'Ловкость': false,
    'Телосложение': false,
    'Интеллект': false,
    'Мудрость': false,
    'Харизма': false,
  };

  int _getFinalStat(int baseValue, int raceBonus, int generatedValue) {
    return (generatedValue != 10 ? generatedValue : baseValue) + raceBonus;
  }

  final List<String> _races = [
    'Человек',
    'Дварф',
    'Полурослик',
    'Эльф',
    'Полуэльф',
    'Гном',
    'Драконорожденный',
    'Полуорк',
    'Тифлинг'
  ];

  final List<String> _classes = [
    'Бард',
    'Варвар',
    'Воин',
    'Волшебник',
    'Друид',
    'Жрец',
    'Колдун',
    'Монах',
    'Паладин',
    'Плут',
    'Следопыт',
    'Чародей'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  final Map<String, int> _abilityChanges =
  {}; // Хранит текущие изменения характеристик

  final Map<String, int> _raceBonuses = {
    'Сила': 0,
    'Ловкость': 0,
    'Телосложение': 0,
    'Интеллект': 0,
    'Мудрость': 0,
    'Харизма': 0,
  };

  // Бонусы от класса
  void _applyClassBonuses(String? newClass) {
  }

  int _calculateHitPoints(String characterClass, int level, int constitutionModifier) {
    final baseHealth = {
      'Бард': 8,
      'Варвар': 12,
      'Воин': 10,
      'Волшебник': 6,
      'Друид': 8,
      'Жрец': 8,
      'Колдун': 6,
      'Монах': 8,
      'Паладин': 10,
      'Плут': 8,
      'Следопыт': 10,
      'Чародей': 6,
    }[characterClass] ?? 6; // Значение по умолчанию, если класс не найден

    // Здоровье на 1 уровне: базовое здоровье + модификатор телосложения
    // На каждом следующем уровне: добавляем (базовое здоровье / 2 + 1) + модификатор телосложения
    if (level == 1) {
      return baseHealth + constitutionModifier;
    } else {
      return baseHealth + constitutionModifier + (level - 1) * ((baseHealth ~/ 2) + 1 + constitutionModifier);
    }
  }

  void _applyRaceBonuses(String? newRace) {
    // Сбрасываем предыдущие бонусы
    if (_previousRace == 'Полуэльф') {
      for (var ability in _selectedHalfElfAbilities) {
        _raceBonuses[ability] = 0;
      }
      _selectedHalfElfAbilities.clear();
    }

    // Сбрасываем все бонусы
    _raceBonuses.forEach((key, value) {
      _raceBonuses[key] = 0;
    });

    // Применяем новые бонусы
    if (newRace == 'Полуэльф') {
      setState(() {
        _showAbilitySelection = true;
        _raceBonuses['Харизма'] = 2;
      });
    } else {
      switch (newRace) {
        case 'Человек':
          _raceBonuses['Сила'] = 1;
          _raceBonuses['Ловкость'] = 1;
          _raceBonuses['Телосложение'] = 1;
          _raceBonuses['Интеллект'] = 1;
          _raceBonuses['Мудрость'] = 1;
          _raceBonuses['Харизма'] = 1;
          break;
        case 'Эльф':
          _raceBonuses['Ловкость'] = 2;
          break;
        case 'Гном':
          _raceBonuses['Интеллект'] = 2;
          break;
        case 'Дварф':
          _raceBonuses['Телосложение'] = 2;
          _raceBonuses['Сила'] = 3;
          break;
        case 'Драконорожденный':
          _raceBonuses['Сила'] = 2;
          _raceBonuses['Харизма'] = 1;
          break;
        case 'Полуорк':
          _raceBonuses['Телосложение'] = 1;
          _raceBonuses['Сила'] = 2;
          break;
        case 'Полурослик':
          _raceBonuses['Ловкость'] = 2;
          break;
        case 'Тифлинг':
          _raceBonuses['Интеллект'] = 1;
          _raceBonuses['Харизма'] = 2;
          break;
      }
      _showAbilitySelection = false;
    }
    _previousRace = newRace;
  }

  void _updateChange(String ability, int delta) {
    _abilityChanges[ability] = (_abilityChanges[ability] ?? 0) + delta;

    // Автоматически очищаем изменения через 1 секунду
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _abilityChanges.remove(ability);
        });
      }
    });
  }

  void _applyAbilityChange(String ability, int value) {
    switch (ability) {
      case 'Сила':
        _strength += value;
        _updateChange(ability, value);
        break;
      case 'Ловкость':
        _dexterity += value;
        _updateChange(ability, value);
        break;
      case 'Телосложение':
        _constitution += value;
        _updateChange(ability, value);
        break;
      case 'Интеллект':
        _intelligence += value;
        _updateChange(ability, value);
        break;
      case 'Мудрость':
        _wisdom += value;
        _updateChange(ability, value);
        break;
      case 'Харизма':
        _charisma += value;
        _updateChange(ability, value);
        break;
    }
  }

  void _saveCharacter() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRace == 'Полуэльф' && _selectedHalfElfAbilities.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите 2 характеристики для полуэльфа!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_generatedStats != null && !_allStatsUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Распределите все сгенерированные значения!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newCharacter = Character(
      id: DateTime.now().toString(),
      name: _nameController.text,
      race: _selectedRace!,
      characterClass: _selectedClass!,
      level: _level,
      strength: _getFinalStat(_strength, _raceBonuses['Сила'] ?? 0, _strength),
      dexterity: _getFinalStat(_dexterity, _raceBonuses['Ловкость'] ?? 0, _dexterity),
      constitution: _getFinalStat(_constitution, _raceBonuses['Телосложение'] ?? 0, _constitution),
      intelligence: _getFinalStat(_intelligence, _raceBonuses['Интеллект'] ?? 0, _intelligence),
      wisdom: _getFinalStat(_wisdom, _raceBonuses['Мудрость'] ?? 0, _wisdom),
      charisma: _getFinalStat(_charisma, _raceBonuses['Харизма'] ?? 0, _charisma),
      armorClass: 10 + _calculateModifier(_dexterity),
      hitPoints: _calculateHitPoints(_selectedClass!, _level, _calculateModifier(_constitution)),
      background: _background,
      proficientSkills: [], // Пустой список умений
    );

    widget.onSave(newCharacter);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SkillsScreen(
          character: newCharacter,
          onSave: (updatedCharacter) {
            // Обновляем список персонажей
            widget.onSave(updatedCharacter);
            // Переходим на PlayerHomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerHomeScreen(
                  isPlayer: true, // или false, в зависимости от вашей логики
                  characters: widget.characters,
                ),
              ),
            );
          },
          characters: widget.characters,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создание персонажа')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 20),
              _buildAbilitiesSection(),
              const SizedBox(height: 20),
              _buildCombatStatsSection(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCharacter,
                child: const Text('Далее'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Основная информация',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Имя персонажа'),
              validator: (value) => value!.isEmpty ? 'Введите имя' : null,
            ),
            DropdownButtonFormField<String>(
              value: _selectedRace,
              decoration: const InputDecoration(labelText: 'Раса'),
              items: _races.map((race) {
                return DropdownMenuItem(
                  value: race,
                  child: Text(race),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _applyRaceBonuses(value);
                  _selectedRace = value;
                });
              },
              validator: (value) => value == null ? 'Выберите расу' : null,
            ),
            Visibility(
              visible: _showAbilitySelection,
              child: Column(
                children: [
                  const Text('Выберите 2 характеристики для увеличения (+1):',
                      style: TextStyle(fontSize: 16)),
                  Wrap(
                    spacing: 8,
                    children: [
                      'Сила',
                      'Ловкость',
                      'Телосложение',
                      'Интеллект',
                      'Мудрость',
                    ].map((ability) {
                      final isSelected =
                      _selectedHalfElfAbilities.contains(ability);
                      return ChoiceChip(
                        label: Text(ability),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              if (_selectedHalfElfAbilities.length < 2) {
                                _selectedHalfElfAbilities.add(ability);
                                _applyAbilityChange(ability, 1);
                              }
                            } else {
                              _selectedHalfElfAbilities.remove(ability);
                              _applyAbilityChange(ability, -1);
                            }
                          });
                        },
                        selectedColor: Colors.green[100],
                      );
                    }).toList(),
                  ),
                  if (_selectedHalfElfAbilities.length != 2 &&
                      _showAbilitySelection)
                    const Text('Выберите ровно 2 характеристики!',
                        style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: const InputDecoration(labelText: 'Класс'),
              items: _classes.map((cls) {
                return DropdownMenuItem(
                  value: cls,
                  child: Text(cls),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _applyClassBonuses(value);
                  _selectedClass = value;
                });
              },
              validator: (value) => value == null ? 'Выберите класс' : null,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Уровень'),
              initialValue: _level.toString(),
              validator: (value) {
                if (value!.isEmpty) return 'Введите уровень';
                final level = int.tryParse(value);
                if (level == null || level < 1 || level > 20) {
                  return 'Уровень должен быть от 1 до 20';
                }
                return null;
              },
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final level = int.tryParse(value);
                  if (level != null && level >= 1 && level <= 20) {
                    setState(() {
                      _level = level;
                      _hitPoints = _calculateHitPoints(_selectedClass ?? 'Воин', _level, _calculateModifier(_constitution));
                    });
                  }
                }
              },
              onSaved: (value) => _level = int.parse(value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbilitiesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Характеристики',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Ручной ввод'),
                    onPressed: _showManualInputDialog,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8), // Уменьшаем отступы
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Уменьшаем расстояние между кнопками
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.casino),
                    label: const Text('Автозаполнение'),
                    onPressed: _generateRandomStats,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8), // Уменьшаем отступы
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_generatedStats != null) // Показываем только если есть сгенерированные значения
              Column(
                children: [
                  Wrap(
                    spacing: 8,
                    children: _generatedStats!.map((stat) => _buildStatDraggable(stat)).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _allStatsUsed
                        ? '✓ Все значения использованы'
                        : '⚠ Осталось ${_generatedStats!.where((s) => !s.isUsed).length} неиспользованных',
                    style: TextStyle(
                      color: _allStatsUsed ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            _buildStatDropTarget('Сила', _strength, (v) => setState(() => _strength = v)),
            _buildStatDropTarget('Ловкость', _dexterity, (v) => setState(() => _dexterity = v)),
            _buildStatDropTarget('Телосложение', _constitution, (v) => setState(() => _constitution = v)),
            _buildStatDropTarget('Интеллект', _intelligence, (v) => setState(() => _intelligence = v)),
            _buildStatDropTarget('Мудрость', _wisdom, (v) => setState(() => _wisdom = v)),
            _buildStatDropTarget('Харизма', _charisma, (v) => setState(() => _charisma = v)),
          ],
        ),
      ),
    );
  }

// Обновленный метод генерации
  void _generateRandomStats() {
    setState(() {
      _strength = 10;
      _dexterity = 10;
      _constitution = 10;
      _intelligence = 10;
      _wisdom = 10;
      _charisma = 10;

      _generatedStats = List.generate(6, (index) =>
          GeneratedStat(index, _roll4d6())
      )..sort((a, b) => b.value.compareTo(a.value));

      _allStatsUsed = false;
      _isStatAssigned = {
        'Сила': false,
        'Ловкость': false,
        'Телосложение': false,
        'Интеллект': false,
        'Мудрость': false,
        'Харизма': false,
      };

      // Пересчитываем класс брони
    });
  }
// Виджет для перетаскивания
  Widget _buildStatDraggable(GeneratedStat stat) {
    return IgnorePointer(
      ignoring: stat.isUsed,
      child: Opacity(
        opacity: stat.isUsed ? 0.5 : 1.0,
        child: Draggable<GeneratedStat>(
          data: stat,
          feedback: Material(
            child: Chip(
              label: Text('${stat.value}'),
              backgroundColor: stat.isUsed ? Colors.grey[300] : null,
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: Chip(
              label: Text('${stat.value}'),
              backgroundColor: stat.isUsed ? Colors.grey[300] : null,
            ),
          ),
          child: Chip(
            label: Text('${stat.value}'),
            backgroundColor: stat.isUsed ? Colors.grey[400] : null,
          ),
        ),
      ),
    );
  }

  Widget _buildStatDropTarget(String label, int currentValue, Function(int) onUpdate) {
    final raceBonus = _raceBonuses[label] ?? 0;
    final finalValue = _getFinalStat(currentValue, raceBonus, currentValue);
    final isAssigned = _isStatAssigned[label] ?? false;

    return DragTarget<GeneratedStat>(
      onWillAccept: (data) => data != null && !data.isUsed,
      onAccept: (stat) {
        setState(() {
          if (currentValue != 10) {
            final oldStat = _generatedStats?.firstWhere(
                  (s) => s.value == currentValue && s.isUsed,
              orElse: () => GeneratedStat(-1, 0),
            );
            if (oldStat != null && oldStat.id != -1) {
              oldStat.isUsed = false;
            }
          }

          stat.isUsed = true;
          onUpdate(stat.value);
          _isStatAssigned[label] = true; // Помечаем характеристику как заполненную

          _allStatsUsed = _generatedStats?.every((s) => s.isUsed) ?? false;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isAssigned ? Colors.green : Colors.grey,
                        width: isAssigned ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isAssigned ? Colors.green.withOpacity(0.1) : null,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isAssigned)
                              const Icon(Icons.check_circle, color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            Text('$label: $finalValue'),
                          ],
                        ),
                        if (raceBonus != 0)
                          Text(
                            '(+$raceBonus от расы)',
                            style: const TextStyle(fontSize: 12, color: Colors.green),
                          ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      if (currentValue != 10) {
                        final stat = _generatedStats?.firstWhere(
                              (s) => s.value == currentValue && s.isUsed,
                          orElse: () => GeneratedStat(-1, 0),
                        );
                        if (stat != null && stat.id != -1) {
                          stat.isUsed = false;
                          _isStatAssigned[label] = false; // Снимаем отметку
                          _allStatsUsed = _generatedStats?.every((s) => s.isUsed) ?? false;
                        }
                        onUpdate(10);
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  int _roll4d6() {
    final rolls = List.generate(4, (_) => Random().nextInt(6) + 1);
    rolls.sort();
    return rolls.sublist(1).reduce((a, b) => a + b);
  }

  void _showManualInputDialog() {
    final formKey = GlobalKey<FormState>();
    final controllers = {
      'Сила': TextEditingController(text: _strength.toString()),
      'Ловкость': TextEditingController(text: _dexterity.toString()),
      'Телосложение': TextEditingController(text: _constitution.toString()),
      'Интеллект': TextEditingController(text: _intelligence.toString()),
      'Мудрость': TextEditingController(text: _wisdom.toString()),
      'Харизма': TextEditingController(text: _charisma.toString()),
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ручной ввод характеристик'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Text('Введите значения от 1 до 20:', style: TextStyle(fontSize: 14)),
                  ...controllers.entries.map((entry) {
                    final label = entry.key;
                    final isAssigned = _isStatAssigned[label] ?? false;

                    return TextFormField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: label,
                        border: const OutlineInputBorder(),
                        filled: isAssigned,
                        fillColor: isAssigned ? Colors.green.withOpacity(0.1) : null,
                        suffixIcon: isAssigned
                            ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите значение';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 1 || number > 20) {
                          return 'Значение должно быть от 1 до 20';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _isStatAssigned[label] = value.isNotEmpty && int.tryParse(value) != null;

                          // Пересчитываем класс брони при изменении ловкости
                          if (label == 'Ловкость') {
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _generatedStats = null;
                    _allStatsUsed = false;

                    _strength = int.parse(controllers['Сила']!.text);
                    _dexterity = int.parse(controllers['Ловкость']!.text);
                    _constitution = int.parse(controllers['Телосложение']!.text);
                    _intelligence = int.parse(controllers['Интеллект']!.text);
                    _wisdom = int.parse(controllers['Мудрость']!.text);
                    _charisma = int.parse(controllers['Харизма']!.text);

                    _isStatAssigned = {
                      'Сила': controllers['Сила']!.text.isNotEmpty,
                      'Ловкость': controllers['Ловкость']!.text.isNotEmpty,
                      'Телосложение': controllers['Телосложение']!.text.isNotEmpty,
                      'Интеллект': controllers['Интеллект']!.text.isNotEmpty,
                      'Мудрость': controllers['Мудрость']!.text.isNotEmpty,
                      'Харизма': controllers['Харизма']!.text.isNotEmpty,
                    };

                    // Пересчитываем класс брони
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  int _calculateModifier(int statValue) {
    if ((statValue - 10) ~/ 2 < 0) return 0;
    return (statValue - 10) ~/ 2; // Целочисленное деление
  }

  Widget _buildCombatStatsSection() {
    final armorClass = 10 + _calculateModifier(_dexterity + _raceBonuses['Ловкость']!); // Рассчитываем класс брони
    final hitPoints = _calculateHitPoints(_selectedClass ?? 'Воин', _level, _calculateModifier(_constitution + _raceBonuses['Телосложение']!));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Боевые характеристики',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: const Text('Класс брони'),
              subtitle: Text('$armorClass'),
            ),
            ListTile(
              title: const Text('Здоровье'),
              subtitle: Text('$hitPoints (${_selectedClass ?? 'Воин'} уровень $_level)'),
            ),
          ],
        ),
      ),
    );
  }
}
