import 'package:karas_quest/control/json/character_data.dart';
import 'package:karas_quest/control/json/tile.dart' as k;

class MapData {
  List<CharacterData> enemies = [];
  String mapFile = '';
  String name = '';
  bool isGenerated = false;
  int seed = 0;
  int width = 0;
  int height = 0;
  int openTiles = 0;
  int spawnChance = 0;
  int maxEnemies = 0;
  int spawnRadius = 0;
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
    isGenerated = mapData['isGenerated'] as bool? ?? false;
    mapFile = mapData['mapFile'] as String? ?? '';
    spawnChance = mapData['spawnChance'] as int? ?? 0;
    seed = mapData['seed'] as int? ?? 0;
    spawnRadius = mapData['spawnRadius'] as int? ?? 0;
    maxEnemies = mapData['maxEnemies'] as int? ?? 0;
    name = mapData['name'] as String? ?? '';
    openTiles = mapData['openTiles'] as int? ?? 0;
    width = mapData['width'] as int? ?? 0;
    height = mapData['height'] as int? ?? 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'name' : name,
      'seed' : seed,
      'spawnChance' : spawnChance,
      'maxEnemies' : maxEnemies,
      'spawnRadius' : spawnRadius,
      'openTiles' : openTiles,
      'width' : width,
      'height' : height,
      'enemies' : enemies.map((enemy) => enemy.toMap()).toList(),
      'mapFile' : mapFile,
      'isGenerated' : isGenerated,
      'playerTile' : playerTile.toMap()
    };
  }
}
