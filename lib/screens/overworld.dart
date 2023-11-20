import 'dart:async';
import 'package:a_star_algorithm/a_star_algorithm.dart' as AStarAlgorithm;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_game/components/enemy.dart';
import 'package:flame_game/components/enemy_creator.dart';
import 'package:flame_game/components/npc.dart';
import 'package:flame_game/components/square.dart';
import 'package:flame_game/components/turn_system.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/control/portal.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';
import 'dart:math' as math;

class Overworld extends World with HasGameRef<MainGame> , TapCallbacks{
  List<List<dynamic>> _blockedTiles = [];
  List<List<dynamic>> _triggerTiles = [];
  List<List<dynamic>> _npcTiles = [];
  List<List<dynamic>> _enemyTiles = [];
  List<Enemy> _enemies = [];
  List<NPC> _npcs = [];
  bool _debugDraw = false;
  bool listenToInput = false;

  String _mapfile = '';
  Vector2 _reEntryPos = Vector2.zero();
  TiledComponent? _tiledmap;
  final enemyCreator = EnemyCreator();
  late final TurnSystem turnSystem;
  List<math.Point<int>> _blockedTileList = [];
  List<Enemy> _enemiesToMove = [];
  
  final List<Square> _squares = [];

  Overworld(this._mapfile);

  @override
  void onMount() {
    super.onMount();
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
    _enemies = _createEnemies(_tiledmap!.tileMap);
    turnSystem = TurnSystem(overworld: this, playerFinishedCallback: (){});
    game.player.position = _readSpawnPoint(_tiledmap!.tileMap);
    game.camera.follow(game.player);
    turnSystem.updateState(TurnSystemState.player);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
  }

  void enemyTurn() {
    _enemiesToMove.addAll(_enemies);
    moveNextEnemy();
  }
  
  void moveNextEnemy() {
    if(_enemiesToMove.isEmpty) {
      turnSystem.updateState(TurnSystemState.enemyFinished);
      return;
    }
    final enemy = _enemiesToMove.last;
    _enemiesToMove.removeLast();
    enemy.move(_findPath(enemy));
  }

  void directionPressed(Direction direction) {
    if(!listenToInput) {
      return;
    }
    game.player.faceDirection(direction);
    if (canMoveDirection(direction)) {
      game.player.move(direction);
    }
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

    if (portal != null) {
      _reEntryPos = Vector2(game.player.position.x, game.player.position.y);
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

    if (game.currentSpeechBubble != null) {
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
    _enemyTiles = _generate2dArray(map.width, map.height);
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
        layersToLoad: ['grass', 'trees', 'rocks', 'building'],
        clear: false);
  }

  void _buildPortals(RenderableTiledMap tileMap) {
    final portalGroup = tileMap.getLayer<ObjectGroup>('portal');
    final exitGroup = tileMap.getLayer<ObjectGroup>('exit');

    if (portalGroup != null) {
      for (final portal in portalGroup.objects) {
        final pos = Vector2(portal.x * 2, portal.y * 2);
        final mapProperty =
            portal.properties.getProperty<StringProperty>('map');
        final map = (mapProperty != null) ? mapProperty.value : '';
        _addPortal(Portal(map, pos));
      }
    }

    if (exitGroup != null) {
      for (final exit in exitGroup.objects) {
        final pos = Vector2(exit.x, exit.y);
        _addExit(pos);
      }
    }
  }

  void _addPortal(Portal portal) {
    final func = () async {
      final map = portal.map;
      await game.overworldNavigator.loadWorld(map);
    };
    final tilePos = posToTile(Vector2(portal.position.x, portal.position.y));
    _triggerTiles[tilePos.x.toInt()][tilePos.y.toInt()] = func;
  }

  void _addExit(Vector2 exit) {
    final func = () async {
      game.overworldNavigator.loadMainWorld();
    };
    final tilePos = posToTile(Vector2(exit.x * 2, exit.y * 2));
    _triggerTiles[tilePos.x.toInt()][tilePos.y.toInt()] = func;
  }

  Vector2 _readSpawnPoint(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>('spawn');
    final spawnObject = objectGroup!.objects.first;
    return Vector2(spawnObject.x * 2, spawnObject.y * 2);
  }

  List<Vector2> _readEnemySpawns(RenderableTiledMap tileMap) {
    final List<Vector2> spawns = [];
    final objectGroup = tileMap.getLayer<ObjectGroup>('enemy');
    if (objectGroup == null) {
      return spawns;
    }

    for(final object in objectGroup.objects) {
      spawns.add(Vector2(object.x * 2, object.y * 2));
    }

    return spawns;
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
      final speechHeight =
          object.properties.getProperty<IntProperty>('speechHeight');
      if (speechHeight != null) {
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

    _blockedTileList.add(math.Point<int>(x, y));
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

  // void playerEntered() async {
  //   if (game.player.parent != null) {
  //     game.player.removeFromParent();
  //   }

  //   _tiledmap?.add(game.player);

  //   if (_reEntryPos.isZero()) {
  //     if(_tiledmap != null){
  //       game.player.position = _readSpawnPoint(_tiledmap!.tileMap);
  //     }
  //     return;
  //   }

  //   game.player.position = _reEntryPos;
  // }

  void _createNpcs() {
    final spawns = _readNpcSpawnPoints(_tiledmap!.tileMap);
    for (final spawnData in spawns) {
      final npc = NPC(spawnData);
      add(npc);
      _npcs.add(npc);
      final tile = posToTile(npc.position);
      _npcTiles[tile.x.toInt()][tile.y.toInt()] = npc;
    }
  }

  List<Enemy> _createEnemies(RenderableTiledMap tileMap) {
    final List<Enemy> enemies = [];
    final spawns = _readEnemySpawns(_tiledmap!.tileMap);
    for (final spawnPos in spawns) {
      final enemy = Enemy(position: spawnPos);
      final tile = posToTile(enemy.position);
      _enemyTiles[tile.x.toInt()][tile.y.toInt()] = enemy;
      enemies.add(enemy);
      add(enemy);
    }
    return enemies;
  }

  NPC? _isTileBlockedNpc(Vector2 nextTile) {
    try {
      return _npcTiles[nextTile.x.toInt()][nextTile.y.toInt()];
    } catch (e) {
      print('error checking tile');
    }
    return null;
  }

  Function? _getTilePortal(Vector2 nextTile) {
    try {
      return _triggerTiles[nextTile.x.toInt()][nextTile.y.toInt()];
    } catch (e) {
      print('error checking tile');
    }
    return null;
  }
  
  Direction _findPath(Enemy enemy) {
    final map = _tiledmap!.tileMap.map;
    final endVec = posToTile(game.player.position);
    final startVec = posToTile(enemy.position);
    final math.Point<int> end = math.Point(endVec.x.toInt(), endVec.y.toInt());
    final math.Point<int> start= math.Point(startVec.x.toInt(), startVec.y.toInt());
    final wallTiles = _blockedTileList;
    final npcTiles = _npcs.map((npc) {
      final tile = posToTile(npc.data.position);
      return math.Point<int>(tile.x.toInt(), tile.y.toInt());
    }).toSet();
    final enemys = _enemies.where((other) => other != enemy);
    final enemyTiles = enemys.map((enemy) {
      final tile = posToTile(enemy.position);
      return math.Point<int>(tile.x.toInt(), tile.y.toInt());
    }).toSet();
    final barriers = Set<math.Point<int>>.from([... wallTiles, ... npcTiles, ... enemyTiles]).toList();
    final result = AStarAlgorithm.AStar(
      rows: map.width, 
      columns: map.height, 
      start: start, 
      end: end, 
      withDiagonal: false,
      barriers: barriers).findThePath(doneList: (doneList) {
    });

    if(result.isEmpty) {
      return Direction.none;
    }

    final tilePath = result.map((point) {
      return tileToPos(Vector2(point.x.toDouble(), point.y.toDouble()));
    }).toList();


    if(_debugDraw) {
      for(final square in _squares) {
        square.removeFromParent();
      }

      for(final tile in tilePath) {
        final square = Square()..position = tile;
        _squares.add(square);
        add(square);
      }
    }

    if(tilePath.length > 1) {
      final tile = tilePath[1];
      // prevent from running over player
      if(posToTile(tile) == posToTile(game.player.position)) {
        return Direction.none;
      }

      final direction = directionFromPosToPos(enemy.position, tile);
      return direction;
    }

    return Direction.none;
  }
}
