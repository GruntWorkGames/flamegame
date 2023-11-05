import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_game/components/player_component.dart';
import 'package:flame_game/components/ui.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';

class Overworld extends World with HasGameRef<MainGame> {
  
  List<List<dynamic>> _blockedTiles = [];
  List<List<dynamic>> _triggerTiles = [];

  @override
  FutureOr<void> onLoad() async {
    game.overworld = this;

    final tiledmap = await TiledComponent.load('map.tmx', Vector2.all(TILESIZE));
    tiledmap.position = Vector2(0, 0);
    tiledmap.anchor = Anchor.topLeft;
    add(tiledmap);
    
    _generateTiles(tiledmap.tileMap.map);
    _buildBlockedTiles(tiledmap.tileMap);

    final player = PlayerComponent(); 
    player.position = _readSpawnPoint(tiledmap.tileMap);
    add(player);
    game.camera.follow(player);

    final ui = UI();
    game.camera.viewport.add(ui);
  }

  bool canMoveDirection(Direction direction){
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
    _blockedTiles = List<List>.generate(map.width, (index) => List<dynamic>.generate(map.height, (index) => false, growable: false), growable: false);
    _triggerTiles = List<List>.generate(map.width, (index) => List<dynamic>.generate(map.height, (index) => null, growable: false), growable: false);
  }
  
  void _buildBlockedTiles(RenderableTiledMap tileMap) async {
    await TileProcessor.processTileType(tileMap: tileMap, processorByType: <String, TileProcessorFunc> {
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
      final func = () {
        print('entered town ${town?.value}');
      };
      _triggerTiles[x][y] = func;
    }
  }
}
