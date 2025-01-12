import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:karas_quest/components/base_map.dart';
import 'package:karas_quest/components/enemy_creator.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/components/player_component.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/enum/item_type.dart';
import 'package:karas_quest/control/json/map_data.dart';
import 'package:karas_quest/control/json/portal.dart';
import 'package:karas_quest/control/objects/floor_factory.dart';

class DungeonMap extends BaseMap with HasGameRef<MainGame> {
  late FloorData _floorData;
  PlayerComponent? player;

  final scene = PositionComponent();
  DungeonMap.fromMapData(MapData map) {
    mapData = map;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    add(scene);
    _floorData = FloorFactory.generate(mapData.width, mapData.height, kTileSize, mapData.openTiles);
    generateTiles(mapData.width, mapData.height);

    tiles = _floorData.bools;
    await _buildTiles();
    player = PlayerComponent();
    player!.data = game.saveFile.playerData;
    player!.position = spawnPoint;
    game.player = player!;
    add(player!);

    final firstItem = player!.data.inventory.first;
    firstItem.isSelected = true;
    final weapon = player!.data.inventory.where((item) => item.isEquipped && item.type == ItemType.weapon).firstOrNull;
    if (weapon != null) {
      player!.weapon = weapon;
    }
    player?.equipWeapon(player!.weapon);
    player?.equipArmor(player!.armor);

    enemyCreator = EnemyCreator(this);
    enemyCreator?.spawnChance = mapData.spawnChance;
    enemyCreator?.maxEnemies = mapData.maxEnemies;
    enemyCreator?.spawnRadius = mapData.spawnRadius;
    await enemyCreator!.loadEnemyFile();
    add(enemyCreator!);
  }

  @override
  Future<void> playerEntered() async {
    if(player != null) {
      game.player = player!;
    }
  }

  Future<void> _buildTiles() async {
    for(var x=0; x<_floorData.width; x++) {
      for(var y=0; y<_floorData.height; y++) {
        final pos = Vector2(x.toDouble() * kTileSize, y.toDouble() * kTileSize);
        await _addFloorSprite(pos);
        if(_floorData.bools[x][y]) {
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
    scene.add(tile);
  }

  Future<void> _addFloorSprite(Vector2 pos) async {
    final image = await game.images.load('grass_tileset_16x16.png');
    final spriteSheet = SpriteSheet(image: image, srcSize: Vector2(16, 16));
    final sprite = spriteSheet.getSprite(7, 0);
    final tile = SpriteComponent(sprite: sprite);
    tile.position = pos;
    scene.add(tile);
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
  Vector2 get spawnPoint => tileToPos(_floorData.spawnTile);

  @override
  int get tilesHigh => mapData.height;

  @override
  int get tilesWide => mapData.width;
}