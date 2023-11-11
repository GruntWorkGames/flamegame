import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_game/components/npc.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/control/portal.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';

class Overworld extends World with HasGameRef<MainGame> {
  List<List<dynamic>> _blockedTiles = [];
  List<List<dynamic>> _triggerTiles = [];
  List<List<dynamic>> _npcTiles = [];
  String _mapfile = '';
  Vector2 _reEntryPos = Vector2.zero();
  TiledComponent? _tiledmap;

  Overworld(this._mapfile);

  @override
  void onMount() {
    playerEntered();
    final ui = game.ui;
    if (ui.parent == null) {
      game.camera.viewport.add(ui);
    }
    game.camera.follow(game.player);
  }

  @override
  FutureOr<void> onLoad() async {
    _tiledmap = await TiledComponent.load(_mapfile, Vector2.all(TILESIZE));
    _tiledmap?.anchor = Anchor.topLeft;
    add(_tiledmap!);
    _generateTiles(_tiledmap!.tileMap.map);
    _buildBlockedTiles(_tiledmap!.tileMap);
    _buildPortals(_tiledmap!.tileMap);
    _createNpcs();

    game.player.position = _readSpawnPoint(_tiledmap!.tileMap);
    game.camera.follow(game.player);
  }

  bool canMoveDirection(Direction direction) {
    final playerPos = posToTile(game.player.position);
    final nextTile = getNextTile(direction, playerPos);
    final npc = _isTileBlockedNpc(nextTile);
    final portal = _getTilePortal(nextTile);
    if (npc != null) {
      npc.speak();
      return false;
    }

    if(portal != null) {
      portal();
      return false;
    }

    return !isTileBlocked(nextTile);
  }
// 1120 x 832
  bool isTileBlocked(Vector2 pos) {
    try {
      return _blockedTiles[pos.x.toInt()][pos.y.toInt()];
    } catch (e) {
      print('error checking if tile is blocked at: ${pos.x}, ${pos.y}');
      print(e.toString());
    }
    return false;
  }

  void steppedOnTile(Vector2 pos) {
    // try {
    //   final func = _triggerTiles[pos.x.toInt()][pos.y.toInt()];
    //   if (func != null) {
    //     func();
    //   }
    // } catch (e) {
    //   print('error checking tile');
    // }

    if(game.currentSpeechBubble != null) {
      game.currentSpeechBubble!.removeFromParent();
      game.currentSpeechBubble = null;
    }
  }

  void _generateTiles(TiledMap map) {
    _blockedTiles = List<List>.generate(
        map.width,
        (index) => List<dynamic>.generate(map.height, (index) => false,
            growable: false),
        growable: false);

    _triggerTiles = _generate2dArray(map.width, map.height);
    _npcTiles = _generate2dArray(map.width, map.height);
  }

  List<List<dynamic>> _generate2dArray(int width, int height) {
    return List<List>.generate(
        width,
        (index) =>
            List<dynamic>.generate(height, (index) => null, growable: false),
        growable: false);
  }

  void _buildBlockedTiles(RenderableTiledMap tileMap) async {
    await TileProcessor.processTileType(
        tileMap: tileMap,
        processorByType: <String, TileProcessorFunc>{
          'blocked': ((tile, position, size) async {
            _addBlockedCell(position);
          }),
        },
        layersToLoad: [
          'grass',
          'trees',
          'rocks',
          'building'
        ],clear: false);
  }

  void _buildPortals(RenderableTiledMap tileMap) {
    final portalGroup = tileMap.getLayer<ObjectGroup>('portal');
    final exitGroup = tileMap.getLayer<ObjectGroup>('exit');

    if(portalGroup != null) { 
      for(final portal in portalGroup.objects) {
        final pos = Vector2(portal.x*2, portal.y*2);
        final mapProperty = portal.properties.getProperty<StringProperty>('map');
        final map = (mapProperty != null) ? mapProperty.value : '';
        _addPortal(Portal(map, pos));
      }
    }

    if(exitGroup != null) {
      for(final exit in exitGroup.objects) {
        final pos = Vector2(exit.x, exit.y);
        _addExit(pos);
      }
    }
  }

  void _addPortal(Portal portal) {
    final func = () async {
      final map = portal.map;
      _reEntryPos = Vector2(portal.position.x, portal.position.y);
      await game.overworldNavigator.loadWorld(map);
    };
    final tilePos = posToTile(Vector2(portal.position.x, portal.position.y));
    _triggerTiles[tilePos.x.toInt()][tilePos.y.toInt()] = func;
  }

  void _addExit(Vector2 exit) {
    final func = () async {
      game.overworldNavigator.loadMainWorld();
    };
     final tilePos = posToTile(Vector2(exit.x*2, exit.y*2));
    _triggerTiles[tilePos.x.toInt()][tilePos.y.toInt()] = func;
  }

  Vector2 _readSpawnPoint(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>('spawn');
    final spawnObject = objectGroup!.objects.first;
    return Vector2(spawnObject.x * 2, spawnObject.y * 2);
  }

  List<NpcData> _readNpcSpawnPoints(RenderableTiledMap tilemap) {
    List<NpcData> spawnData = [];
    final objectGroup = tilemap.getLayer<ObjectGroup>('npc');
    if (objectGroup == null) {
      return spawnData;
    }

    for (final object in objectGroup.objects) {
      NpcData data = NpcData();
      final speech = object.properties.getProperty<StringProperty>('speech');
      if (speech != null) {
        data.speech = speech.value;
      }
      final speechHeight = object.properties.getProperty<IntProperty>('speechHeight');
      if(speechHeight != null) {
        data.speechHeight = speechHeight.value;
      }
      data.name = object.name;
      data.position = Vector2(object.x * 2, object.y * 2);
      spawnData.add(data);
    }
    return spawnData;
  }

  void _addBlockedCell(Vector2 position) {
    // because we upscale to 32x32
    position.x *= 2;
    position.y *= 2;
    final t = posToTile(position);

    int x = t.x.toInt();
    int y = t.y.toInt();
    _blockedTiles[x][y] = true;
  }

  void playerEntered() async {
    if (game.player.parent != null) {
      game.player.removeFromParent();
    }

    _tiledmap?.add(game.player);

    if (_reEntryPos.isZero()) {
      return;
    }
    game.player.position = _reEntryPos;
  }

  void _createNpcs() {
    final spawns = _readNpcSpawnPoints(_tiledmap!.tileMap);
    for (final spawnData in spawns) {
      final npc = NPC(spawnData);
      add(npc);
      final tile = posToTile(npc.position);
      _npcTiles[tile.x.toInt()][tile.y.toInt()] = npc;
    }
  }

  NPC? _isTileBlockedNpc(Vector2 nextTile) {
    return _npcTiles[nextTile.x.toInt()][nextTile.y.toInt()];
  }
  
  Function? _getTilePortal(Vector2 nextTile) {
    try {
        return _triggerTiles[nextTile.x.toInt()][nextTile.y.toInt()];
      } catch (e) {
      print('error checking tile');
    }
    return null;
  }
}
