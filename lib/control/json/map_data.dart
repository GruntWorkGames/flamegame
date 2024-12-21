import 'package:karas_quest/control/json/character_data.dart';
import 'package:karas_quest/control/objects/tile.dart' as k;

class MapData {
  List<CharacterData> enemies = [];
  String mapFile = '';
  k.Tile playerTile = k.Tile(0, 0);
  MapData();

  MapData.fromJson(Map<String, dynamic> mapData) {
    final enemyList = mapData['enemies'] as List<dynamic>? ?? [];
    for (final enemy in enemyList) {
      final enemyNode = enemy as Map<String, dynamic>? ?? {};
      enemies.add(CharacterData.fromMap(enemyNode));
    }

    final tileNode = mapData['playerTile'] as Map<String, dynamic>? ?? {};
    playerTile.x = tileNode['x'] as int? ?? 0;
    playerTile.y = tileNode['y'] as int? ?? 0;

    mapFile = mapData['mapFile'] as String? ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'enemies' : enemies.map((enemy) => enemy.toMap()).toList(),
      'mapFile' : mapFile,
      'playerTile' : playerTile.toMap()
    };
  }
}
