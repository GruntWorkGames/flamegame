import 'package:karas_quest/control/json/tile.dart';

class GeneratedMap {
    Tile playerTile = Tile(0, 0);
    int width = 0;
    int height = 0;
    int numOpenTiles = 0;
    int seed = 0;
    GeneratedDungeonEnemyParams enemyStats = GeneratedDungeonEnemyParams();
  
    GeneratedMap();
  
    GeneratedMap.fromJson(Map<String, dynamic> json) {
      width = json['width'] as int? ?? 0;
      height = json['height'] as int? ?? 0;
      seed = json['seed'] as int? ?? 0;
      numOpenTiles =  json['numOpenTiles'] as int? ?? 0;
      final tileNode = json['playerTile'] as Map<String, dynamic>? ?? {};
      playerTile = Tile.fromMap(tileNode);
      enemyStats = GeneratedDungeonEnemyParams.fromMap(json['enemyParams'] as Map<String, dynamic>? ?? {});
    }
  
    Map<String, dynamic> toJson() {
      return {
        'width': width,
        'height': height,
        'seed' : seed,
        'numOpenTiles': numOpenTiles,
        'playerTile': playerTile.toMap(),
        'enemyParams': enemyStats.toMap(),
      };
    }
  }
  
  class GeneratedDungeonEnemyParams {
    int minLevel = 0;
    int maxLevel = 0;
    int maxEnemies = 0;
  
    GeneratedDungeonEnemyParams();
  
    GeneratedDungeonEnemyParams.fromMap(Map<String, dynamic> map) {
      minLevel = map['minLevel'] as int? ?? 0;
      maxLevel = map['maxLevel'] as int? ?? 0;
      maxEnemies = map['maxEnemies'] as int? ?? 0;
    }
  
    Map<String, dynamic> toMap() {
      return {
        'minLevel': minLevel,
        'maxLevel': maxLevel,
        'maxEnemies': maxEnemies,
      };
    }
  }