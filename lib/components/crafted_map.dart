import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';
import 'package:flutter/material.dart';
import 'package:karas_quest/components/base_map.dart';
import 'package:karas_quest/components/enemy_creator.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/components/npc.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/json/map_data.dart';
import 'package:karas_quest/control/objects/portal.dart';
import 'package:karas_quest/control/objects/tile.dart' as k;

class CraftedMap extends BaseMap{
  late final TiledComponent tiledmap;
  CraftedMap(super.game, super.mapData, super.enemyCreator);

  @override
  Future<void> init() async {
    tiledmap = await TiledComponent.load(mapData.mapFile, Vector2.all(kTileSize.toDouble()));
    tiledmap.anchor = Anchor.topLeft;
    generateTiles(mapWidth, mapHeight);
    await buildBlockedTiles(tiledmap.tileMap);
    buildPortals(tiledmap.tileMap);
    initEnemyCreatorSpecs();
  }

  @override int get mapWidth => tiledmap.tileMap.map.width;
  @override int get mapHeight => tiledmap.tileMap.map.height;
  @override int get mapWidthPixels => mapWidth * kTileSize;
  @override int get mapHeightPixels => mapHeight * kTileSize;

  @override
  void initEnemyCreatorSpecs() {
    enemyCreator.spawnChance = tiledmap.tileMap.map.properties.getProperty<IntProperty>('spawnChance')?.value ?? 0;
    enemyCreator.maxEnemies = tiledmap.tileMap.map.properties.getProperty<IntProperty>('maxEnemies')?.value ?? 0;
    enemyCreator.spawnRadius = tiledmap.tileMap.map.properties.getProperty<IntProperty>('spawnRadius')?.value ?? 0;
  }

  @override
  Future<void> buildBlockedTiles(RenderableTiledMap tileMap) async {
    final tileLayers = tileMap.renderableLayers.where((element) {
      return element.layer.type == LayerType.tileLayer;
    });

    final layerNames = tileLayers.map((element) {
      return element.layer.name;
    }).toList();

    try {
      await TileProcessor.processTileType(
        tileMap: tileMap,
        processorByType: <String, TileProcessorFunc>{
          'blocked': (tile, position, size) async {
            addBlockedCell(position);
          },
        },
        layersToLoad: layerNames,
        clear: false,
      );
    } on Exception catch (e) {
      debugPrint('Error processing tile type: $e');
    }
  }

  @override
  void buildPortals(RenderableTiledMap tileMap) {
    final portalGroup = tileMap.getLayer<ObjectGroup>('portal');
    final exitGroup = tileMap.getLayer<ObjectGroup>('exit');

    if (portalGroup != null) {
      for (final portal in portalGroup.objects) {
        final pos = Vector2(portal.x, portal.y);
        final mapProperty = portal.properties.getProperty<StringProperty>('map');
        final map = (mapProperty != null) ? mapProperty.value : '';
        addPortal(Portal(map, pos));
      }
    }

    if (exitGroup != null) {
      for (final exit in exitGroup.objects) {
        final pos = Vector2(exit.x, exit.y);
        addExit(pos);
      }
    }
  }

  @override
  Vector2 readPlayerSpawnPoint() {
    final objectGroup = tiledmap.tileMap.getLayer<ObjectGroup>('spawn');
    final spawnObject = objectGroup!.objects.first;
    return Vector2(spawnObject.x, spawnObject.y);
  }
}