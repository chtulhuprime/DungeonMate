import 'dart:convert';

class Spell {
  final String id;
  final String name;
  final String description;
  final String fullDescription;
  final String imageUrl;
  final String school; // Например: "fire", "ice", "arcane"
  final int level;
  final Map<String, dynamic> characteristics; // { "damage": 10, "range": 30 }

  Spell({
    required this.id,
    required this.name,
    required this.description,
    required this.fullDescription,
    required this.imageUrl,
    required this.school,
    required this.level,
    required this.characteristics,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'fullDescription': fullDescription,
      'imageUrl': imageUrl,
      'school': school,
      'level': level,
      'characteristics': jsonEncode(characteristics),
    };
  }

  factory Spell.fromJson(Map<String, dynamic> json) {
    return Spell(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      fullDescription: json['fullDescription'],
      imageUrl: json['imageUrl'],
      school: json['school'],
      level: json['level'],
      characteristics: jsonDecode(json['characteristics']),
    );
  }
}