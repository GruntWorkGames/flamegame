import 'dart:async';
import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';
import 'package:flutter/services.dart';
import 'package:karas_quest/components/base_map.dart';
import 'package:karas_quest/components/enemy.dart';
import 'package:karas_quest/components/enemy_creator.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/components/npc.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/enum/direction.dart';
import 'package:karas_quest/control/enum/map_type.dart';
import 'package:karas_quest/control/json/map_data.dart';
import 'package:karas_quest/control/json/npc_data.dart';
import 'package:karas_quest/control/json/portal.dart';
import 'package:karas_quest/control/json/tile.dart' as k;

mixin PortalDelegate {
  Future<void> portalEntered(Portal portal);
}

class WorldMap extends BaseMap with HasGameRef<MainGame> {
  MapData mapData = MapData();
  PortalDelegate? _portalDelegate;
  List<List<bool>> tiles = [];
  List<Vector2> openTiles = [];
  List<List<Function?>> _triggerTiles = [];
  final List<NPC> _npcs = [];
  TiledComponent? tiledmap;
  final List<k.Tile> blockedTileList = [];
  final _aggroDistance = 6;
  bool listenToInput = true;
  final List<Enemy> _enemiesToMove = [];
  bool shouldContinue = false; // player continuoue movement
  Direction lastDirection = Direction.none;
  Vector2 playerPos = Vector2.zero();

  WorldMap.fromMapData(MapData map) {
    mapData = map;
    playerPos = tileToPos(map.playerTile);
  }

  set portalDelegate(PortalDelegate delegate) {
    _portalDelegate = delegate;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    tiledmap = await TiledComponent.load(mapData.mapFile, Vector2.all(kTileSize.toDouble()));
    tiledmap?.anchor = Anchor.topLeft;
    add(tiledmap!);
    generateTiles(tiledmap!.tileMap.map.width, tiledmap!.tileMap.map.height);
    _buildBlockedTiles(tiledmap!.tileMap);

    final isSavedTileZero = game.player.data.tilePosition.x == 0 && game.player.data.tilePosition.y == 0;
    final isPlayerAtZero = game.player.position.isZero();

    if (!isSavedTileZero && isPlayerAtZero) {
      game.player.position = tileToPos(game.player.data.tilePosition);
    } else {
      game.player.position = spawnPoint;
    }

    game.player.data.tilePosition = posToTile(game.player.position);

    playerEntered();
    await _createNpcs();
  }

  void _addBlockedCell(Vector2 position) {
    final tile = posToTile(position);
    tiles[tile.x][tile.y] = true;
    // _blockedTileList.add(tile);
  }

  Future<void> _buildBlockedTiles(RenderableTiledMap tileMap) async {
    final tileLayers = tileMap.renderableLayers.where((element) {
      return element.layer.type == LayerType.tileLayer;
    });

    final layerNames = tileLayers.map((element) {
      return element.layer.name;
    },).toList();
    
    try{
      await TileProcessor.processTileType(
        tileMap: tileMap,
        processorByType: <String, TileProcessorFunc> {
          'blocked': (tile, position, size) async {
            _addBlockedCell(position);
          },
        },
        layersToLoad: layerNames,
        clear: false);
    } on Exception catch(e, st) {
      print('Error processing blocked tiles: $e');
      print(st);
    }
  }


  @override
  List<NPC> get npcs => _npcs;

  @override
  List<Portal> get portals => throw UnimplementedError();

  Future<void> _createNpcs() async {
    final spawns = await _createNpcData(tiledmap!.tileMap);
    for (final spawnData in spawns) {
      final npc = NPC(spawnData);
      add(npc);
      _npcs.add(npc);
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

  void _buildPortals(RenderableTiledMap tileMap) {
    final portalGroup = tileMap.getLayer<ObjectGroup>('portal');
    final exitGroup = tileMap.getLayer<ObjectGroup>('exit');

    if (portalGroup != null) {
      for (final portal in portalGroup.objects) {
        final pos = Vector2(portal.x, portal.y);
        final mapProperty = portal.properties.getProperty<StringProperty>('map');
        final dungeonProperty = portal.properties.getProperty<StringProperty>('dungeon');
        final map = (mapProperty != null) ? mapProperty.value : '';
        final dungeon = dungeonProperty != null ?  dungeonProperty.value : '';
        final file = dungeon.isEmpty ? map : dungeon;
        final type = dungeon.isEmpty ? MapType.crafted : MapType.generated;
        _addPortal(Portal(file, pos, type));
      }
    }

    if (exitGroup != null) {
      for (final exit in exitGroup.objects) {
        final pos = Vector2(exit.x, exit.y);
        _addExit(pos);
      }
    }
  }
  
  void _addExit(Vector2 exit) {
    void func() {
      game.mapLoader.popWorld();
    }
    final tilePos = posToTile(Vector2(exit.x, exit.y));
    _triggerTiles[tilePos.x][tilePos.y] = func;
  }

  void _addPortal(Portal portal) {
    final tilePos = posToTile(portal.position);
    _triggerTiles[tilePos.x][tilePos.y] = () {
      _portalDelegate?.portalEntered(portal);
    };
  }
  
  @override
  double get pixelsWide {
    return tiledmap?.width ?? 0;
}
  
  @override
  double get pixelsHigh { 
    return tiledmap?.height ?? 0;
  }
  
  @override
  Vector2 get spawnPoint {
    if(tiledmap != null) {
      final objectGroup = tiledmap!.tileMap.getLayer<ObjectGroup>('spawn');
      final spawnObject = objectGroup!.objects.first;
      return Vector2(spawnObject.x, spawnObject.y);
    } else {
      return Vector2.zero();
    }
  }
  
  @override
  void playerEntered() {
    tiledmap?.add(game.player);
  }
}