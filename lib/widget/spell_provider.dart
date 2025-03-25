import 'package:dungeon_mate/widget/spell.dart';
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/characters.dart';

class SpellProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Spell> _spells = [];
  List<Spell> _characterSpells = [];
  Character? _selectedCharacter;

  List<Spell> get spells => _spells;
  List<Spell> get characterSpells => _characterSpells;
  Character? get selectedCharacter => _selectedCharacter;

  Future<void> loadAllSpells() async {
    _spells = await _dbHelper.getAllSpells();
    notifyListeners();
  }

  Future<void> selectCharacter(Character character) async {
    _selectedCharacter = character;
    await loadCharacterSpells();
  }

  Future<void> loadCharacterSpells() async {
    if (_selectedCharacter == null) return;
    _characterSpells = await _dbHelper.getCharacterSpells(_selectedCharacter!.id);
    notifyListeners();
  }

  Future<void> addSpellToCharacter(Spell spell) async {
    if (_selectedCharacter == null) return;
    await _dbHelper.addSpellToCharacter(_selectedCharacter!.id, spell.id);
    await loadCharacterSpells();
  }
}