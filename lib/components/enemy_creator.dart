import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_game/components/enemy.dart';
import 'package:flame_game/components/game.dart';
import 'package:flame_game/constants.dart';
import 'dart:math' as math;

class EnemyCreator extends Component with HasGameRef<MainGame> {
  final Random random = Random();

  // co effecient on how likely this zone is to spawn a monster
  int spawnChance = 10;

  EnemyCreator() : super();

  void playerMoved() {
    final r = random.nextInt(100) + 1;
    if(r <= spawnChance) {
      _createEnemy();
    }
  }

  void _createEnemy() {
    final spawnArea = game.overworld?.tilesArroundPosition(posToTile(game.player.position), 13).map((point) => Vector2(point.x.toDouble(), point.y.toDouble())).toList() ?? [];
    if(spawnArea.isEmpty) {
      throw Exception('Spawn Area is empty');
    }

    spawnArea.removeWhere((tile) => game.overworld!.isTileBlocked(tile));

    final enemyTiles = game.overworld?.enemies.map((enemy) {
      final tile = posToTile(enemy.position);
      return math.Point<int>(tile.x.toInt(), tile.y.toInt());
    }).toList() ?? [];

    spawnArea.removeWhere((tilePos) => enemyTiles.contains(tilePos));

    final index = Random().nextInt(spawnArea.length);
    final spawnTile = spawnArea[index];
    final enemy = Enemy();
    enemy.position = tileToPos(spawnTile);
    game.overworld?.enemies.add(enemy);
    game.overworld?.add(enemy);
  }
}
