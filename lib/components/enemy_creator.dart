import 'dart:convert';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:karas_quest/components/enemy.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/control/constants.dart';

class EnemyCreator extends Component with HasGameRef<MainGame> {
  final Random random = Random();

  // co effecient on how likely this zone is to spawn a monster
  int spawnChance = 0;
  int maxEnemies = 0;
  int spawnRadius = 0;
  List<String> enemies = [];

  EnemyCreator() : super();

  Future<void> loadEnemyFile() async {
    final json = await rootBundle.loadString('assets/json/enemies.json');
    final map = jsonDecode(json) as Map<String, dynamic>? ?? {};
    final enemyList = map['enemies'] as List<dynamic>? ?? [];
    for(final enemy in enemyList) {
      if(enemy is String) {
        enemies.add(enemy);
      }
    }
  }

  void playerMoved() {
    final r = random.nextInt(100) + 1;
    if(r <= spawnChance) {
      _createEnemy();
    }
  }

  void _createEnemy() {
    if((game.mapRunner?.enemies.length ?? 0) >= maxEnemies) {
      return;
    }

    final spawnArea = game.mapRunner?.tilesArroundPosition(posToTile(game.player.position), spawnRadius) ?? [];
    if(spawnArea.isEmpty) {
      throw Exception('Spawn Area is empty');
    }

    final enemyTiles = game.mapRunner?.enemies.map((enemy) {
      return posToTile(enemy.position);
    }).toList() ?? [];

    spawnArea.removeWhere((tile) {
      return 
        tile == posToTile(game.player.position)
          || enemyTiles.contains(tile)
          || game.mapRunner!.isTileBlocked(tile);
    });

    final index = Random().nextInt(spawnArea.length);
    final spawnTile = spawnArea[index];
    final enemyJsonFile = randomEnemyFile();
    final enemy = Enemy(enemyJsonFile);
    enemy.position = tileToPos(spawnTile);
    game.mapRunner?.enemies.add(enemy);
    game.mapRunner?.add(enemy);
  }

  String randomEnemyFile() {
    final r = random.nextInt(enemies.length);
    return enemies[r];
  }
}
