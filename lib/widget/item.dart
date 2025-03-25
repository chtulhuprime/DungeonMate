import 'dart:convert';

class Item {
  final String id;
  final String name;
  final String description;
  final String fullDescription;
  final String imageUrl;
  final Map<String, dynamic> characteristics;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.fullDescription,
    required this.imageUrl,
    required this.characteristics,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'fullDescription': fullDescription,
      'imageUrl': imageUrl,
      'characteristics': jsonEncode(characteristics),
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      fullDescription: json['fullDescription'],
      imageUrl: json['imageUrl'],
      characteristics: jsonDecode(json['characteristics']),
    );
  }
}