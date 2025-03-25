import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/characters.dart';
import 'item.dart';

class InventoryProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Item> _allItems = [];
  List<Item> _characterItems = [];
  Character? _selectedCharacter;

  List<Item> get allItems => _allItems;
  List<Item> get characterItems => _characterItems;
  Character? get selectedCharacter => _selectedCharacter;

  Future<void> loadAllItems() async {
    _allItems = await _dbHelper.getAllItems();
    notifyListeners();
  }

  Future<void> selectCharacter(Character character) async {
    _selectedCharacter = character;
    await loadCharacterInventory();
  }

  Future<void> loadCharacterInventory() async {
    if (_selectedCharacter == null) return;
    _characterItems = await _dbHelper.getCharacterInventory(_selectedCharacter!.id);
    notifyListeners();
  }

  Future<void> addItemToCharacter(Item item) async {
    if (_selectedCharacter == null) return;
    await _dbHelper.addItemToCharacter(_selectedCharacter!.id, item.id);
    await loadCharacterInventory();
  }

  Future<void> removeItemFromCharacter(Item item) async {
    if (_selectedCharacter == null) return;
    await _dbHelper.removeItemFromCharacter(_selectedCharacter!.id, item.id);
    await loadCharacterInventory();
  }
}