import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';

class Overworld extends World with HasGameRef<MainGame> {
  List<List<dynamic>> _blockedTiles = [];
  List<List<dynamic>> _triggerTiles = [];
  String _mapfile = '';
  Vector2? _reEntryPos;
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

    game.player.position = _readSpawnPoint(_tiledmap!.tileMap);
    game.camera.follow(game.player);
  }

  bool canMoveDirection(Direction direction) {
    final playerPos = posToTile(game.player.position);
    final nextTile = getNextTile(direction, playerPos);
    return !isTileBlocked(nextTile);
  }

  bool isTileBlocked(Vector2 pos) {
    try {
      return _blockedTiles[pos.x.toInt()][pos.y.toInt()];
    } catch(e) {
      print('error checking if tile is blocked');
    }
    return false;
  }

  void steppedOnTile(Vector2 pos) {
    try {
      final func = _triggerTiles[pos.x.toInt()][pos.y.toInt()];
      if(func != null) {
        func();
      }
    } catch(e) {
      print('error checking tile');
    }
  }
  
  void _generateTiles(TiledMap map) {
    _blockedTiles = List<List>.generate(map.width, (index) => 
    List<dynamic>.generate(map.height, (index) => 
    false, growable: false), growable: false);

    _triggerTiles = List<List>.generate(map.width, (index) => 
    List<dynamic>.generate(map.height, (index) => 
    null, growable: false), growable: false);
  }
  
  void _buildBlockedTiles(RenderableTiledMap tileMap) async {
    await TileProcessor.processTileType(tileMap: tileMap, 
    processorByType: <String, TileProcessorFunc> {
      'blocked': ((tile, position, size) async {
        _addBlockedCell(position);
      }),
      'building': ((tile, position, size) async {
        _addBuilding(position, tile);
      }),
    }, layersToLoad: [
      'grass', 'trees', 'rocks', 'building',
    ]);
  }
  
  Vector2 _readSpawnPoint(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>('spawn');
    final spawnObject = objectGroup!.objects.first;
    return Vector2(spawnObject.x*2, spawnObject.y*2);
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

  void _addBuilding(Vector2 position, TileProcessor tile) {
    position.x *= 2;
    position.y *= 2;
    final t = posToTile(position);
    int x = t.x.toInt();
    int y = t.y.toInt();

    final properties = tile.tile.properties;
    if(properties.has('town')) {
      final town = properties.getProperty<StringProperty>('town');
      final func = () async {
        final map = town?.value;
        if(map != null) {
          _reEntryPos = Vector2(x*TILESIZE, y*TILESIZE);
          await game.overworldNavigator.loadWorld(map);
        }
      };
      _triggerTiles[x][y] = func;
    }

    if(properties.has('exit')) {
      final func = () async {
        game.overworldNavigator.loadMainWorld();
      };
      _triggerTiles[x][y] = func;
    }
  }

  void playerEntered() async {
    if (game.player.parent != null) {
      game.player.removeFromParent();
    }

    _tiledmap?.add(game.player);

    if (_reEntryPos == null) {
      return;
    }
    game.player.position = _reEntryPos!;
  }
}
