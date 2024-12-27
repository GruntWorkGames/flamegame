
import 'package:flame_tiled/flame_tiled.dart';
import 'package:karas_quest/components/enemy_creator.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/components/npc.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/json/map_data.dart';
import 'package:karas_quest/control/objects/portal.dart';
import 'package:karas_quest/control/objects/tile.dart' as k;
import 'package:vector_math/vector_math_64.dart';

abstract class BaseMap {
  int get mapWidth => 0;
  int get mapHeight => 0;
  int get mapWidthPixels => 0;
  int get mapHeightPixels => 0;

  final MainGame game;
  final MapData mapData;
  final EnemyCreator enemyCreator;
  
  List<List<bool>> blockedTiles = [];
  List<List<Function?>> triggerTiles = [];
  List<List<NPC?>> npcTiles = [];
  final List<k.Tile> blockedTileList = [];

  BaseMap(this.game, this.mapData, this.enemyCreator);

  // abstract methods
  Future<void> init();
  void initEnemyCreatorSpecs();
  void buildPortals(RenderableTiledMap tileMap);
  Future<void> buildBlockedTiles(RenderableTiledMap tileMap);
  Vector2 readPlayerSpawnPoint();

  // inherited methods
  void generateTiles(int width, int height) {
    blockedTiles = List<List<bool>>.generate(
        width,
        (index) => List<bool>.generate(height, (index) => false, growable: false),
        growable: false);

    triggerTiles = List<List<Function?>>.generate(
        width,
        (index) => List<Function?>.generate(height, (index) => null, growable: false),
        growable: false);

    npcTiles = List<List<NPC?>>.generate(
        width,
        (index) => List<NPC?>.generate(height, (index) => null, growable: false),
        growable: false);
  }

  void addBlockedCell(Vector2 position) {
    final tile = posToTile(position);
    blockedTiles[tile.x][tile.y] = true;
    blockedTileList.add(tile);
  }

  void addPortal(Portal portal) {
    final tilePos = posToTile(portal.position);
    triggerTiles[tilePos.x][tilePos.y] = () {
      game.mapRunner?.portalEntered(portal);
    };
  }

  void addExit(Vector2 exit) {
    final tilePos = posToTile(exit);
    triggerTiles[tilePos.x][tilePos.y] = game.mapLoader.popWorld;
  }
}