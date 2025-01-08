import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:karas_quest/components/base_map.dart';
import 'package:karas_quest/components/enemy.dart';
import 'package:karas_quest/components/enemy_creator.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/components/npc.dart';
import 'package:karas_quest/control/enum/direction.dart';
import 'package:karas_quest/control/json/map_data.dart';
import 'package:karas_quest/control/json/portal.dart';
import 'package:karas_quest/control/json/tile.dart' as k;

class WorldMap extends Component with HasGameRef<MainGame>, BaseMap {
  MapData mapData = MapData();
  List<List<bool>> blockedTiles = [];
  List<Vector2> openTiles = [];
  List<List<Function?>> _triggerTiles = [];
  List<List<NPC?>> _npcTiles = [];
  final List<NPC> _npcs = [];
  TiledComponent? tiledmap;
  final enemyCreator = EnemyCreator();
  final List<k.Tile> blockedTileList = [];
  final _aggroDistance = 6;
  bool listenToInput = true;
  final List<Enemy> _enemiesToMove = [];
  bool shouldContinue = false; // player continuoue movement
  Direction lastDirection = Direction.none;

  // serializable properties
  List<Enemy> _enemies = [];

  @override
  FutureOr<void> onLoad() {
    return super.onLoad();
  }

  @override
  List<Enemy> get enemies => throw UnimplementedError();

  @override
  int get height => throw UnimplementedError();

  @override
  List<NPC> get npcs => throw UnimplementedError();

  @override
  List<Portal> get portals => throw UnimplementedError();

  @override
  List<List<k.Tile>> get tiles => throw UnimplementedError();

  @override
  int get width => throw UnimplementedError();
}