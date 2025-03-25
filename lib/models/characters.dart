import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../widget/spell.dart';
import 'character.dart';
import '../widget/item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'characters.db');
    debugPrint('Database path: $path');

    return await openDatabase(
      path,
      version: 3, // Увеличьте версию базы данных
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await _createTables(db);
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // Таблица персонажей
    await db.execute('''
      CREATE TABLE IF NOT EXISTS characters(
        id TEXT PRIMARY KEY,
        name TEXT,
        race TEXT,
        characterClass TEXT,
        level INTEGER,
        strength INTEGER,
        dexterity INTEGER,
        constitution INTEGER,
        intelligence INTEGER,
        wisdom INTEGER,
        charisma INTEGER,
        armorClass INTEGER,
        hitPoints INTEGER,
        background TEXT,
        proficientSkills TEXT
      )
    ''');

    // Таблица предметов
    await db.execute('''
      CREATE TABLE IF NOT EXISTS items(
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        fullDescription TEXT,
        imageUrl TEXT,
        characteristics TEXT
      )
    ''');

    // Таблица инвентаря персонажей
    await db.execute('''
      CREATE TABLE IF NOT EXISTS character_items(
        character_id TEXT,
        item_id TEXT,
        quantity INTEGER DEFAULT 1,
        PRIMARY KEY (character_id, item_id),
        FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
        FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
      )
    ''');

    // Таблица заклинаний
    await db.execute('''
      CREATE TABLE IF NOT EXISTS spells(
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        fullDescription TEXT,
        imageUrl TEXT,
        school TEXT,
        level INTEGER,
        characteristics TEXT
      )
    ''');

    // Таблица связи персонажей и заклинаний
    await db.execute('''
      CREATE TABLE IF NOT EXISTS character_spells(
        character_id TEXT,
        spell_id TEXT,
        FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
        FOREIGN KEY (spell_id) REFERENCES spells(id) ON DELETE CASCADE,
        PRIMARY KEY (character_id, spell_id)
      )
    ''');
  }

  // Методы для работы с заклинаниями
  Future<void> insertSpell(Spell spell) async {
    final db = await database;
    await db.insert('spells', spell.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Spell>> getAllSpells() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('spells');
    return List.generate(maps.length, (i) => Spell.fromJson(maps[i]));
  }

  Future<void> addSpellToCharacter(String characterId, String spellId) async {
    final db = await database;
    await db.insert('character_spells', {
      'character_id': characterId,
      'spell_id': spellId,
    });
  }

  Future<List<Spell>> getCharacterSpells(String characterId) async {
    final db = await database;
    final maps = await db.query(
      'character_spells',
      where: 'character_id = ?',
      whereArgs: [characterId],
    );

    final List<Spell> spells = [];
    for (final map in maps) {
      final spellMaps = await db.query(
        'spells',
        where: 'id = ?',
        whereArgs: [map['spell_id']],
      );
      if (spellMaps.isNotEmpty) {
        spells.add(Spell.fromJson(spellMaps.first));
      }
    }
    return spells;
  }

  // Методы для работы с предметами
  Future<void> insertItem(Item item) async {
    final db = await database;
    await db.insert('items', item.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Item>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) => Item.fromJson(maps[i]));
  }

  // Методы для работы с инвентарем персонажа
  Future<void> addItemToCharacter(String characterId, String itemId, [int quantity = 1]) async {
    final db = await database;
    await db.insert(
      'character_items',
      {
        'character_id': characterId,
        'item_id': itemId,
        'quantity': quantity,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeItemFromCharacter(String characterId, String itemId) async {
    final db = await database;
    await db.delete(
      'character_items',
      where: 'character_id = ? AND item_id = ?',
      whereArgs: [characterId, itemId],
    );
  }

  Future<List<Item>> getCharacterInventory(String characterId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'character_items',
      where: 'character_id = ?',
      whereArgs: [characterId],
    );

    final List<Item> items = [];
    for (final map in maps) {
      final itemMaps = await db.query(
        'items',
        where: 'id = ?',
        whereArgs: [map['item_id']],
      );
      if (itemMaps.isNotEmpty) {
        items.add(Item.fromJson(itemMaps.first));
      }
    }
    return items;
  }

  Future<void> insertSampleItems() async {
    final db = await database;

    final sampleItems = [
      Item(
        id: '1',
        name: 'Зелье здоровья',
        description: 'Восстанавливает 50 HP',
        fullDescription: 'Магическое зелье, мгновенно восстанавливающее 50 очков здоровья',
        imageUrl: 'images.png',
        characteristics: {'health': 50},
      ),
      Item(
        id: '2',
        name: 'Меч рыцаря',
        description: '+10 к атаке',
        fullDescription: 'Прочный стальной меч, увеличивающий силу атаки',
        imageUrl: 'assets/images.png',
        characteristics: {'attack': 10},
      ),
      Item(
        id: '3',
        name: 'Щит защитника',
        description: '+5 к защите',
        fullDescription: 'Тяжелый металлический щит, повышающий защиту',
        imageUrl: 'assets/shield.png',
        characteristics: {'defense': 5},
      )
    ];

    for (final item in sampleItems) {
      await db.insert('items', item.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final spells = [
      Spell(
        id: '1',
        name: 'Огненный шар',
        description: 'Наносит урон огнем',
        fullDescription: 'Создает взрывающийся шар огня, наносящий 8d6 урона',
        imageUrl: 'assets/images/spells/fireball.png',
        school: 'fire',
        level: 3,
        characteristics: {'damage': '8d6', 'range': 150},
      ),
      Spell(
        id: '2',
        name: 'Лечение ран',
        description: 'Восстанавливает здоровье',
        fullDescription: 'Восстанавливает 1d8+5 очков здоровья',
        imageUrl: 'assets/images/spells/heal.png',
        school: 'healing',
        level: 1,
        characteristics: {'healing': '1d8+5', 'range': 'touch'},
      ),
    ];

    for (final spell in spells) {
      await db.insert('spells', spell.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // Добавление персонажа
  Future<void> insertCharacter(Character character) async {
    final db = await database;
    await db.insert('characters', character.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Получение всех персонажей
  Future<List<Character>> getCharacters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('characters');
    return List.generate(maps.length, (i) => Character.fromJson(maps[i]));
  }

  // Удаление персонажа
  Future<void> deleteCharacter(String id) async {
    final db = await database;
    await db.delete('characters', where: 'id = ?', whereArgs: [id]);
  }
}