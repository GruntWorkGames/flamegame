import 'dart:async';
import 'dart:convert';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karas_quest/components/base_map.dart';
import 'package:karas_quest/components/enemy_creator.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/components/npc.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/json/map_data.dart';
import 'package:karas_quest/control/json/npc_data.dart';
import 'package:karas_quest/control/objects/portal.dart';
import 'package:karas_quest/control/objects/tile.dart' as k;

class CraftedMap extends BaseMap {
  late final TiledComponent tiledmap;

  CraftedMap(super.mapData);

  @override
  Future<void> init() async {
    super.init();
    tiledmap = await TiledComponent.load(mapData.mapFile, Vector2.all(kTileSize.toDouble()));
    tiledmap.anchor = Anchor.topLeft;
    add(tiledmap);
    generateTiles(mapWidth, mapHeight);
    await buildBlockedTiles(tiledmap.tileMap);
    buildPortals(tiledmap.tileMap);
    initEnemyCreatorSpecs();
    await _createNpcs();
    await _createEnemies();
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

  Future<void> _createNpcs() async {  
    final spawns = await _createNpcData(tiledmap.tileMap);
    for (final spawnData in spawns) {
      final npc = NPC(spawnData);
      add(npc);
      npcs.add(npc);
      final tile = posToTile(npc.position);
      npcTiles[tile.x][tile.y] = npc;
    }
  }

    Future<List<NpcData>> _createNpcData(RenderableTiledMap tilemap) async {
    final spawnData = <NpcData>[];
    final objectGroup = tilemap.getLayer<ObjectGroup>('npc');
    if (objectGroup == null) {
      return spawnData;
    }

    for (final object in objectGroup.objects) {
      var data =  NpcData();
      final npcFile = object.properties.getProperty<StringProperty>('npcDataFile');
      if(npcFile != null) {
        final jsonFile = npcFile.value;
        final jsonString = await rootBundle.loadString(jsonFile);
        final map = jsonDecode(jsonString) as Map<String, dynamic>? ?? {};
        data = NpcData.fromMap(map);
      }

      final speech = object.properties.getProperty<StringProperty>('speech');
      if (speech != null) {
        data.speech = speech.value;
      }

      final jsonFile = object.properties.getProperty<StringProperty>('shopFile');
      if (jsonFile != null) {
        data.shopJsonFile = jsonFile.value;
      }

      final animationFile =
          object.properties.getProperty<StringProperty>('animationFile');
      if (animationFile != null) {
        data.animationJsonFile = animationFile.value;
      }

      if(object.name.isNotEmpty) {
        data.name = object.name;
      }
      
      data.position = Vector2(object.x, object.y);
      spawnData.add(data);
    }
    return spawnData;
  }

  Future<void> _createEnemies() async {
    for(final enemyData in mapData.enemies) {
        enemyCreator.createEnemyFromCharacterData(enemyData);
    }
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