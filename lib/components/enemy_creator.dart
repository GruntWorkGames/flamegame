import 'dart:convert';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karas_quest/components/enemy.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/json/character_data.dart';

mixin EnemyCreatedDelegate {
  void enemyCreated(Enemy enemy);
}

class EnemyCreator extends Component with HasGameRef<MainGame> {
  final Random random = Random();

  // co effecient on how likely this zone is to spawn a monster
  int spawnChance = 0;
  int maxEnemies = 0;
  int spawnRadius = 0;
  List<String> enemyFileNames = [];
  final Component _enemyParent;

  EnemyCreatedDelegate? enemyCreatedDelegate;

  EnemyCreator(this._enemyParent);

  Future<void> loadEnemyFile() async {
    final json = await rootBundle.loadString('assets/json/enemies.json');
    final map = jsonDecode(json) as Map<String, dynamic>? ?? {};
    final enemyFileList = map['enemies'] as List<dynamic>? ?? [];
    for(final enemyFileName in enemyFileList) {
      if(enemyFileName is String) {
        enemyFileNames.add(enemyFileName);
      }
    } 
  }

  void createEnemyFromCharacterData(CharacterData character) {
    final enemy = Enemy.fromCharacterData(character);
    game.mapRunner?.enemies.add(enemy);
    game.mapRunner?.add(enemy);
  }

  Enemy? createEnemy() {
    final r = random.nextInt(100) + 1;
    if(r >= spawnChance) {
      return null;
    }

    if((game.mapRunner?.enemies.length ?? 0) >= maxEnemies) {
      return null;
    }

    final spawnArea = game.mapRunner?.tilesArroundPosition(posToTile(game.player.position), spawnRadius) ?? [];
    if(spawnArea.isEmpty) {
      debugPrint('spawn area is empty');
      return null;
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
    enemy.data.tilePosition = spawnTile;
    enemy.position = tileToPos(spawnTile);
    game.mapRunner?.enemies.add(enemy);
    _enemyParent.add(enemy);

    return enemy;
  }

  String randomEnemyFile() {
    final r = random.nextInt(enemyFileNames.length);
    return enemyFileNames[r];
  }
}
