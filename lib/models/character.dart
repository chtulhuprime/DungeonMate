// lib/models/character.dart
class Character {
  final String id;
  final String name;
  final String race;
  final String characterClass;
  final int level;
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final int armorClass;
  final int hitPoints;
  final String background;
  List<String> inventory;
  List<String> proficientSkills;

  Character({
    required this.id,
    required this.name,
    required this.race,
    required this.characterClass,
    required this.level,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    required this.armorClass,
    required this.hitPoints,
    required this.background,
    this.inventory = const ['Меч', 'Щит'],
    this.proficientSkills = const [],
  });

Character copyWith({
  String? id,
  String? name,
  String? race,
  String? characterClass,
  int? level,
  int? strength,
  int? dexterity,
  int? constitution,
  int? intelligence,
  int? wisdom,
  int? charisma,
  int? armorClass,
  int? hitPoints,
  String? background,
  List<String>? proficientSkills,
}) {
  return Character(
    id: id ?? this.id,
    name: name ?? this.name,
    race: race ?? this.race,
    characterClass: characterClass ?? this.characterClass,
    level: level ?? this.level,
    strength: strength ?? this.strength,
    dexterity: dexterity ?? this.dexterity,
    constitution: constitution ?? this.constitution,
    intelligence: intelligence ?? this.intelligence,
    wisdom: wisdom ?? this.wisdom,
    charisma: charisma ?? this.charisma,
    armorClass: armorClass ?? this.armorClass,
    hitPoints: hitPoints ?? this.hitPoints,
    background: background ?? this.background,
    proficientSkills: proficientSkills ?? this.proficientSkills,
  );
}



  // Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'race': race,
      'characterClass': characterClass,
      'level': level,
      'strength': strength,
      'dexterity': dexterity,
      'constitution': constitution,
      'intelligence': intelligence,
      'wisdom': wisdom,
      'charisma': charisma,
      'armorClass': armorClass,
      'hitPoints': hitPoints,
      'background': background,
      'proficientSkills': proficientSkills.join(','), // Сохраняем список как строку
    };
  }

  // Преобразование из JSON
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      race: json['race'],
      characterClass: json['characterClass'],
      level: json['level'],
      strength: json['strength'],
      dexterity: json['dexterity'],
      constitution: json['constitution'],
      intelligence: json['intelligence'],
      wisdom: json['wisdom'],
      charisma: json['charisma'],
      armorClass: json['armorClass'],
      hitPoints: json['hitPoints'],
      background: json['background'],
      proficientSkills: (json['proficientSkills'] as String).split(','), // Восстанавливаем список
    );
  }
}