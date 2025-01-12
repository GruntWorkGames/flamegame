import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:karas_quest/components/base_map.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/json/map_data.dart';
import 'package:karas_quest/control/json/portal.dart';
import 'package:karas_quest/control/objects/floor_factory.dart';

class DungeonMap extends BaseMap with HasGameRef<MainGame> {
  final MapData mapData;
  late FloorData _floorData;
  DungeonMap.fromMapData(this.mapData);

  @override
  FutureOr<void> onLoad() async {
    _floorData = FloorFactory.generate(mapData.width, mapData.height, kTileSize, mapData.openTiles);
    generateTiles(mapData.width, mapData.height);
    tiles = _floorData.bools;
    await _buildTiles();

    game.player.removeFromParent();
    add(game.player);
    game.player.position = Vector2(4, 4);

    return super.onLoad();
  }

  Future<void> _buildTiles() async {
    for(var x=0; x<_floorData.width; x++) {
      for(var y=0; y<_floorData.height; y++) {
        final pos = Vector2(x.toDouble() * kTileSize, y.toDouble() * kTileSize);
        await _addFloorSprite(pos);
        if(!_floorData.bools[x][y]) {
          await _addWallSprite(pos);
        }
      }
    }
  }

  Future<void> _addWallSprite(Vector2 pos) async {
    final image = await game.images.load('Rocks.png');
    final spriteSheet = SpriteSheet(image: image, srcSize: Vector2(16, 16));
    final sprite = spriteSheet.getSprite(0, 0);
    final tile = SpriteComponent(sprite: sprite);
    tile.position = pos;
    add(tile);
  }

  Future<void> _addFloorSprite(Vector2 pos) async {
    final image = await game.images.load('grass_tileset_16x16.png');
    final spriteSheet = SpriteSheet(image: image, srcSize: Vector2(16, 16));
    final sprite = spriteSheet.getSprite(7, 0);
    final tile = SpriteComponent(sprite: sprite);
    tile.position = pos;
    add(tile);
  }

  @override
  List<Portal> get portals => [];

  @override
  double get pixelsHigh {
    return kTileSize * mapData.height.toDouble();
  }
  
  @override
  double get pixelsWide {
    return kTileSize * mapData.width.toDouble();
  }
  
  @override
  void playerEntered() {
  }
  
  @override
  Vector2 get spawnPoint => Vector2(0, 0);
}