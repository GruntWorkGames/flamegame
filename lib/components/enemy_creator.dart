import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_game/components/enemy.dart';
import 'package:flame_game/components/game.dart';
import 'package:flame_game/control/constants.dart';

class EnemyCreator extends Component with HasGameRef<MainGame> {
  final Random random = Random();

  // co effecient on how likely this zone is to spawn a monster
  int spawnChance = 0;
  int maxEnemies = 0;
  int spawnRadius = 0;

  EnemyCreator() : super();

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
    final enemy = Enemy();
    enemy.position = tileToPos(spawnTile);
    game.mapRunner?.enemies.add(enemy);
    game.mapRunner?.add(enemy);
  }
}
