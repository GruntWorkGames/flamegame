import 'package:flame_game/control/json/character_data.dart';

class OverworldData {
  final List<CharacterData> enemies = [];

  OverworldData();

  OverworldData.fromJson(Map<String, dynamic> json) {
    final enemiesNode = json['enemies'] ?? [];
    for (final json in enemiesNode) {
      enemies.add(CharacterData.fromJson(json));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    json['enemies'] = enemies.map((enemy) => enemy.toJson()).toList();

    return json;
  }
}
