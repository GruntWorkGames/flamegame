import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';
import 'package:flutter/material.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/json/npc_data.dart';
import 'package:karas_quest/control/objects/portal.dart';
import 'package:karas_quest/control/objects/tile.dart' as k;

mixin GameMap {
  List<k.Tile> blockedTileList = [];
  List<List<dynamic>> blockedTiles = [];
  List<Vector2> openTiles = [];
  List<List<dynamic>> triggerTiles = [];
  List<List<dynamic>> npcTiles = [];

  // void buildBlockedTiles(RenderableTiledMap tileMap);
  // void buildPortals(RenderableTiledMap tileMap);
  // Vector2 readPlayerSpawnPoint(RenderableTiledMap tileMap);
  // List<Vector2> readEnemySpawns(RenderableTiledMap tileMap);
  // List<NpcData> readNpcSpawnPoints(RenderableTiledMap tilemap);

  /// Creates a 2D array of Vector2 objects for each array
  void allocateArrays(int width, int height) {
    blockedTiles = _generate2dArray(width, height);
    triggerTiles = _generate2dArray(width, height);
    npcTiles = _generate2dArray(width, height);
  }

  List<List<dynamic>> _generate2dArray(int width, int height) {
    return List<List>.generate(
        width,
        (index) =>
            List<dynamic>.generate(height, (index) => null, growable: false),
        growable: false);
  }

  void addBlockedCell(Vector2 position) {
    final tile = posToTile(position);
    blockedTiles[tile.x][tile.y] = true;
    blockedTileList.add(tile);
  }

  void addPortal(Portal portal, Function onTrigger) {
    // TODO(Kris): move this to map runner logic
    // final func = () async {
    //   // shouldContinue = false;
    //   // final map = portal.map;
    //   // await game.overworldNavigator.pushWorld(map);
    // };
    final tilePos = posToTile(Vector2(portal.position.x, portal.position.y));
    triggerTiles[tilePos.x][tilePos.y] = onTrigger;
  }

  void addExit(Vector2 exit, Function onTrigger) {
    // final func = () async {
      // TODO(Kris): move this to map runner logic
      // game.overworldNavigator.popWorld();
    // };
    final tilePos = posToTile(Vector2(exit.x, exit.y));
    triggerTiles[tilePos.x][tilePos.y] = onTrigger;
  }
}

class RandomMap with GameMap {

}

class CraftedMap with GameMap {

  void buildPortals(RenderableTiledMap tileMap) {
    final portalGroup = tileMap.getLayer<ObjectGroup>('portal');
    final exitGroup = tileMap.getLayer<ObjectGroup>('exit');

    if (portalGroup != null) {
      for (final portal in portalGroup.objects) {
        final pos = Vector2(portal.x, portal.y);
        final mapProperty =
            portal.properties.getProperty<StringProperty>('map');
        final map = (mapProperty != null) ? mapProperty.value : '';
        addPortal(Portal(map, pos), (){});
      }
    }

    if (exitGroup != null) {
      for (final exit in exitGroup.objects) {
        final pos = Vector2(exit.x, exit.y);
        addExit(pos, (){});
      }
    }
  }

  List<Vector2> readEnemySpawns(RenderableTiledMap tileMap) {
    final spawns = <Vector2>[];
    final objectGroup = tileMap.getLayer<ObjectGroup>('enemy');
    if (objectGroup == null) {
      return spawns;
    }

    for (final object in objectGroup.objects) {
      spawns.add(Vector2(object.x, object.y));
    }

    return spawns;
  }

  List<NpcData> readNpcSpawnPoints(RenderableTiledMap tilemap) {
    final spawnData = <NpcData>[];
    final objectGroup = tilemap.getLayer<ObjectGroup>('npc');
    if (objectGroup == null) {
      return spawnData;
    }

    for (final object in objectGroup.objects) {
      final data = NpcData();
      final speech = object.properties.getProperty<StringProperty>('speech');
      if (speech != null) {
        data.speech = speech.value;
      }

      final jsonFile = object.properties.getProperty<StringProperty>('shop');
      if (jsonFile != null) {
        data.shopJsonFile = jsonFile.value;
      }

      final animationFile =
          object.properties.getProperty<StringProperty>('animationFile');
      if (animationFile != null) {
        data.animationJsonFile = animationFile.value;
      }

      data.position = Vector2(object.x, object.y);
      spawnData.add(data);
    }
    return spawnData;
  }

  Vector2 readPlayerSpawnPoint(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>('spawn');
    final spawnObject = objectGroup!.objects.first;
    return Vector2(spawnObject.x, spawnObject.y);
  }

  Future<void> buildBlockedTiles(RenderableTiledMap tileMap) async {
    final layerNames = tileMap.renderableLayers.map((element) {
      return element.layer.name;
    },).toList();
    
    try{
      await TileProcessor.processTileType(
        tileMap: tileMap,
        processorByType: <String, TileProcessorFunc>{
          'blocked': (tile, position, size) async {
            addBlockedCell(position);
          },
        },
        layersToLoad: layerNames,
        clear: false);
    } on Exception catch(e, st) {
      debugPrint(e.toString());
      debugPrint(st.toString());
    }
  }
}
