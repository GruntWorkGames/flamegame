import 'dart:async';
import 'package:a_star_algorithm/a_star_algorithm.dart' as AStarAlgorithm;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flame_game/components/enemy.dart';
import 'package:flame_game/components/enemy_creator.dart';
import 'package:flame_game/components/melee_attack_result.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/components/npc.dart';
import 'package:flame_game/components/square.dart';
import 'package:flame_game/components/turn_system.dart';
import 'package:flame_game/control/constants.dart';
import 'package:flame_game/control/enum/item_type.dart';
import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/json/item.dart';
import 'package:flame_game/control/json/shop.dart';
import 'package:flame_game/control/objects/portal.dart';
import 'package:flame_game/control/provider/dialog_provider.dart';
import 'package:flame_game/control/provider/gold_provider.dart';
import 'package:flame_game/control/provider/healthProvider.dart';
import 'package:flame_game/control/provider/shop_item_provider.dart';
import 'package:flame_game/control/provider/shop_provider.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flame_game/control/enum/direction.dart';
import 'package:flame_game/components/game.dart';
import 'package:flame_game/screens/view/debug/enemies_enabled_provider.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame_game/control/objects/tile.dart' as k;

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

  /** 
   * Creates a 2D array of Vector2 objects for each array
   */
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
    final t = posToTile(position);
    int x = t.x.toInt();
    int y = t.y.toInt();
    blockedTiles[x][y] = true;
    blockedTileList.add(k.Tile(x, y));
  }

  void addPortal(Portal portal, Function onTrigger) {
    // TODO: move this to map runner logic
    // final func = () async {
    //   // shouldContinue = false;
    //   // final map = portal.map;
    //   // await game.overworldNavigator.pushWorld(map);
    // };
    final tilePos = posToTile(Vector2(portal.position.x, portal.position.y));
    triggerTiles[tilePos.x.toInt()][tilePos.y.toInt()] = onTrigger;
  }

  void addExit(Vector2 exit, Function onTrigger) {
    // final func = () async {
      // TODO: move this to map runner logic
      // game.overworldNavigator.popWorld();
    // };
    final tilePos = posToTile(Vector2(exit.x, exit.y));
    triggerTiles[tilePos.x.toInt()][tilePos.y.toInt()] = onTrigger;
  }
}

// class RandomMap with GameMap {

// }

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
    final List<Vector2> spawns = [];
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

      final jsonFile = object.properties.getProperty<StringProperty>('shop');
      if (jsonFile != null) {
        data.shopJsonFile = jsonFile.value;
      }

      final animationFile =
          object.properties.getProperty<StringProperty>('animationFile');
      if (animationFile != null) {
        data.animationJsonFile = animationFile.value;
      }

      data.name = object.name;
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

  void buildBlockedTiles(RenderableTiledMap tileMap) async {
    final layerNames = tileMap.renderableLayers.map((element) {
      return element.layer.name;
    },).toList();
    
    try{
    final what = await TileProcessor.processTileType(
        tileMap: tileMap,
        processorByType: <String, TileProcessorFunc>{
          'blocked': ((tile, position, size) async {
            addBlockedCell(position);
          }),
        },
        layersToLoad: layerNames,
        clear: false);
        print(what);
    } on Exception catch(e, st) {
      print(e);
      print(st);
    }
  }
}

class MapRunner extends World with HasGameRef<MainGame>, TapCallbacks {
  List<List<dynamic>> blockedTiles = [];
  List<Vector2> openTiles = [];
  List<List<dynamic>> _triggerTiles = [];
  List<List<dynamic>> _npcTiles = [];
  List<Enemy> enemies = [];
  List<NPC> _npcs = [];
  String _mapfile = '';
  Vector2 _reEntryPos = Vector2.zero();
  TiledComponent? tiledmap;
  final enemyCreator = EnemyCreator();
  final List<Square> _squares = [];
  List<k.Tile> _blockedTileList = [];
  double zoomFactor = 2.4;

  final _aggroDistance = 6;
  bool listenToInput = false;
  late final TurnSystem turnSystem;
  List<Enemy> _enemiesToMove = [];
  bool shouldContinue = false; // player continuoue movement
  Direction lastDirection = Direction.none;

  MapRunner(this._mapfile);

  @override
  void onMount() {
    super.onMount();
    playerEntered();
  }

  @override
  FutureOr<void> onLoad() async {
    tiledmap = await TiledComponent.load(_mapfile, Vector2.all(TILESIZE.toDouble()));
    tiledmap?.anchor = Anchor.topLeft;
    enemyCreator.spawnChance = tiledmap?.tileMap.map.properties
            .getProperty<IntProperty>('spawnChance')
            ?.value ??
        0;
    enemyCreator.maxEnemies = tiledmap?.tileMap.map.properties
            .getProperty<IntProperty>('maxEnemies')
            ?.value ??
        0;
    enemyCreator.spawnRadius = tiledmap?.tileMap.map.properties
            .getProperty<IntProperty>('spawnRadius')
            ?.value ??
        0;
    add(enemyCreator);
    add(tiledmap!);
    _generateTiles(tiledmap!.tileMap.map);
    _buildBlockedTiles(tiledmap!.tileMap);
    _buildPortals(tiledmap!.tileMap);
    _createNpcs();
    enemies = _createEnemies(tiledmap!.tileMap);
    turnSystem = TurnSystem(overworld: this, playerFinishedCallback: () {});
    // game.camera.follow(game.player);
    turnSystem.updateState(TurnSystemState.player);
    game.ref?.read(uiProvider.notifier).set(UIViewDisplayType.game);
    game.camera.viewfinder.zoom = zoomFactor;
    game.player.data.tilePosition = posToTile(game.player.position);
    final isSavedTileZero = game.player.data.tilePosition.x == 0 && game.player.data.tilePosition.y == 0;
    final isPlayerAtZero = game.player.position.isZero();
    final isMapMatch = game.player.data.mapfile == _mapfile;
    // new game?
    if (!isSavedTileZero && isPlayerAtZero && isMapMatch) {
      game.player.position = tileToPos(game.player.data.tilePosition);
    } else {
      game.player.position = _readPlayerSpawnPoint(tiledmap!.tileMap);
    }

    game.player.data.mapfile = _mapfile;
    game.player.data.tilePosition = posToTile(game.player.position);

    updateUI();
  }

  // TODO: change tilemap.height to a map bounds, so that generated maps work too.
  @override
  void update(double dt) {
    final minDistanceX = (game.size.x / 2 / zoomFactor);
    final minDistanceY = (game.size.y / 2 / zoomFactor);
    final maxDistX = (tiledmap?.width ?? 0) - game.size.x / 2 / zoomFactor;
    final maxDistanceY = (tiledmap?.height ?? 0) - game.size.y / 2 / zoomFactor;
    final camPos = game.player.position.clone();

    if(camPos.x < minDistanceX 
    && camPos.x > maxDistX
    && camPos.y < minDistanceY
    && camPos.y > maxDistanceY) {
      game.camera.viewfinder.position = Vector2(80, 96);
      return;
    } else if (maxDistanceY < 0) {
      game.camera.viewfinder.position = Vector2(80, 96);
      return;
    }
    
    if(camPos.x < minDistanceX) {
      camPos.x = minDistanceX;
    }
    if(camPos.x > maxDistX) {
      camPos.x = maxDistX;
    }

    if(camPos.y < minDistanceY) {
      camPos.y = minDistanceY;
    }
    if(camPos.y > maxDistanceY) {
      camPos.y = maxDistanceY;
    }
    
    game.camera.viewfinder.position = camPos;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
  }

  void enemyTurn() {
    _enemiesToMove.addAll(getEnemiesWithinRange(_aggroDistance));
    moveNextEnemy();
  }

  void moveNextEnemy() {
    if (_enemiesToMove.isEmpty) {
      turnSystem.updateState(TurnSystemState.enemyFinished);
      return;
    }
    final enemy = _enemiesToMove.last;
    _enemiesToMove.removeLast();

    // if enemy is next to the player
    final playerDirection = enemyCanAttackPlayer(enemy);
    if (playerDirection == Direction.none) {
      enemy.move(findPath(enemy));
    } else {
      enemyAttackPlayer(enemy, playerDirection);
    }
  }

  Direction enemyCanAttackPlayer(Enemy enemy) {
    // if player is either above, below, right or left
    final playerTile = posToTile(game.player.position);
    final enemyTile = posToTile(enemy.position);

    final difX = playerTile.x - enemyTile.x;
    final difY = playerTile.y - enemyTile.y;

    if (difX.abs() == 1 || difY.abs() == 1) {
      return directionFromPosToPos(enemyTile, playerTile);
    }

    return Direction.none;
  }

  Vector2 combatTextPositionForEntity(PositionComponent entity) {
    final pos = game.player.position.clone();
    if(entity.position.y == game.player.position.y) {
      pos.y -= TILESIZE;
    }
    if (entity.position.x == game.player.position.x) {
      pos.x += TILESIZE;
    }
    return pos;
  }

  void enemyAttackPlayer(Enemy enemy, Direction playerDirection) {
    final pos = game.player.position.clone();
    if(enemy.position.y == game.player.position.y) {
      pos.y -= TILESIZE;
    }

    if(!enemy.attemptAttack()) {
      enemyMissed(enemy, playerDirection);
      return;
    }

    var damage = enemy.weapon.value;
    if (enemy.position.x == game.player.position.x) {
      pos.x += TILESIZE;
    }

    enemy.playAttackDirectionAnim(playerDirection, () {
      var attackResult = game.player.takeHit(damage, () {
        game.ref?.read(healthProvider.notifier).set(game.player.data.health);
        enemy.onMoveCompleted(posToTile(enemy.position));
      }, () {
        // on death callback
        game.ref?.read(healthProvider.notifier).set(game.player.data.health);
        game.player.removeFromParent();

        final dialog = DialogData();
        dialog.title = 'You have died';
        dialog.message = 'Press here to restart';
        game.ref?.read(dialogProvider.notifier).set(dialog);
        game.ref?.read(uiProvider.notifier).set(UIViewDisplayType.gameOver);
      });

      final damageString = attackResult.value == 0 ? '' : '-${attackResult.value.toInt()}';
      final resultString = attackResult.result == MeleeAttackResult.success ? '' : attackResult.result.name;  
      showCombatMessage(pos,'$resultString $damageString', Color.fromARGB(249, 255, 96, 96));
    });
  }

  void directionPressed(Direction direction) {
    if (!listenToInput) {
      return;
    }
    game.player.faceDirection(direction);
    final enemy = getEnemyInDirection(direction);
    if (enemy != null) {
      fightDirectionPressed(enemy, direction);
      listenToInput = false;
    } else if (canMoveDirection(direction)) {
      game.player.move(direction);
      listenToInput = false;
    }
    lastDirection = direction;
  }

  void fightDirectionPressed(Enemy enemy, Direction direction) {
    if (!listenToInput) {
      return;
    }

    if(game.player.attemptAttack()) {
      playerMissed(enemy, direction);
      return;
    }

    final pos = enemy.position.clone();
    if(enemy.position.y == game.player.position.y) {
      pos.y -= TILESIZE;
    }
    if (enemy.position.x == game.player.position.x) {
      pos.x -= TILESIZE + TILESIZE/2;
    }
    
    game.player.playAttackDirectionAnim(direction, () {
      final damageDone = enemy.takeHit(game.player.weapon.value, () {
        game.overworld!.turnSystem.updateState(TurnSystemState.playerFinished);
      }, () {
        game.player.data.gold += enemy.data.gold;
        game.player.data.experience += enemy.experience;
        updateUI();
        enemy.removeFromParent();
        enemies.removeWhere((other) => other == enemy);
        game.overworld!.turnSystem.updateState(TurnSystemState.playerFinished);
      });
        final damageString = damageDone.value == 0 ? '' : '-${damageDone.value.toInt()}';
        final resultString = damageDone.result == MeleeAttackResult.success ? '' : damageDone.result.name;
        showCombatMessage(pos, '$resultString $damageString',Color.fromARGB(250, 255, 255, 255));
      });
  }
 
  void playerMissed(MeleeCharacter enemy, Direction direction) {
    final pos = enemy.position.clone();
    if(enemy.position.y == game.player.position.y) {
      pos.y -= TILESIZE;
    }
    if (enemy.position.x == game.player.position.x) {
      pos.x -= TILESIZE;
    }
    game.player.playAttackDirectionAnim(direction, () {
      game.overworld!.turnSystem.updateState(TurnSystemState.playerFinished);
      showCombatMessage(pos, 'miss',Color.fromARGB(250, 255, 255, 255));
    });
  }

  void enemyMissed(MeleeCharacter enemy, Direction direction) {
    final pos = game.player.position.clone();
    if(enemy.position.y == game.player.position.y) {
      pos.y -= TILESIZE;
    }
    if (enemy.position.x == game.player.position.x) {
      pos.x += TILESIZE;
    }
    enemy.playAttackDirectionAnim(direction, () {
      showCombatMessage(pos,'miss', Color.fromARGB(249, 255, 96, 96));
      enemy.onMoveCompleted(posToTile(enemy.position));
    });
  }

  Enemy? getEnemyInDirection(Direction direction) {
    final playerTile = posToTile(game.player.position);
    final nextTile = getNextTile(direction, playerTile);
    for (final enemy in enemies) {
      final npcTile = posToTile(enemy.position);
      if (nextTile == npcTile) {
        return enemy;
      }
    }

    return null;
  }

  bool canMoveDirection(Direction direction) {
    final playerPos = posToTile(game.player.position);
    final nextTile = getNextTile(direction, playerPos);
    final npc = _isTileBlockedNpc(nextTile);
    final portal = _getTilePortal(nextTile);
    if (npc != null) {
      showDialog(npc);
      return false;
    }

    if (portal != null) {
      _reEntryPos = Vector2(game.player.position.x, game.player.position.y);
      shouldContinue = false;
      portal();
      return false;
    }

    return !isTileBlocked(nextTile);
  }

  void showDialog(NPC npc) {
    if (npc.npc.shopJsonFile.isNotEmpty) {
      showShop(npc);
      return;
    }

    final dialog = DialogData();
    dialog.title = npc.npc.name;
    dialog.message = npc.npc.speech;
    game.ref?.read(dialogProvider.notifier).set(dialog);
    game.ref?.read(uiProvider.notifier).set(UIViewDisplayType.dialog);
  }

  void showShop(NPC npc) async {
    final json = await game.assets.readJson(npc.npc.shopJsonFile);
    final shop = Shop.fromJson(json);
    game.ref?.read(shopProvider.notifier).set(shop);
    final firstItem = shop.items.first;
    firstItem.isSelected = true;
    game.ref?.read(shopItemProvider.notifier).set(firstItem);
    game.ref?.read(uiProvider.notifier).set(UIViewDisplayType.shop);
  }

  bool isTileBlocked(k.Tile pos) {
    try {
      return blockedTiles[pos.x][pos.y];
    } catch (e) {
      print('error checking if tile is blocked at: ${pos.x}, ${pos.y}');
      print(e.toString());
    }
    return false;
  }

  void steppedOnTile(k.Tile tile) {
    if (game.currentSpeechBubble != null) {
      game.currentSpeechBubble!.removeFromParent();
      game.currentSpeechBubble = null;
    }
  }

  void _generateTiles(TiledMap map) {
    blockedTiles = List<List>.generate(
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
    final layerNames = tileMap.renderableLayers.map((element) {
      return element.layer.name;
    },).toList();
    
    try{
    final what = await TileProcessor.processTileType(
        tileMap: tileMap,
        processorByType: <String, TileProcessorFunc>{
          'blocked': ((tile, position, size) async {
            _addBlockedCell(position);
          }),
        },
        layersToLoad: layerNames,
        clear: false);
        print(what);
    } on Exception catch(e, st) {
      print(e);
      print(st);
    }
  }

  void _buildPortals(RenderableTiledMap tileMap) {
    final portalGroup = tileMap.getLayer<ObjectGroup>('portal');
    final exitGroup = tileMap.getLayer<ObjectGroup>('exit');

    if (portalGroup != null) {
      for (final portal in portalGroup.objects) {
        final pos = Vector2(portal.x, portal.y);
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
      shouldContinue = false;
      final map = portal.map;
      await game.overworldNavigator.pushWorld(map);
    };
    final tilePos = posToTile(Vector2(portal.position.x, portal.position.y));
    _triggerTiles[tilePos.x.toInt()][tilePos.y.toInt()] = func;
  }

  void _addExit(Vector2 exit) {
    final func = () async {
      game.overworldNavigator.popWorld();
    };
    final tilePos = posToTile(Vector2(exit.x, exit.y));
    _triggerTiles[tilePos.x.toInt()][tilePos.y.toInt()] = func;
  }

  Vector2 _readPlayerSpawnPoint(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>('spawn');
    final spawnObject = objectGroup!.objects.first;
    return Vector2(spawnObject.x, spawnObject.y);
  }

  List<Vector2> _readEnemySpawns(RenderableTiledMap tileMap) {
    final List<Vector2> spawns = [];
    final objectGroup = tileMap.getLayer<ObjectGroup>('enemy');
    if (objectGroup == null) {
      return spawns;
    }

    for (final object in objectGroup.objects) {
      spawns.add(Vector2(object.x, object.y));
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

      final jsonFile = object.properties.getProperty<StringProperty>('shop');
      if (jsonFile != null) {
        data.shopJsonFile = jsonFile.value;
      }

      final animationFile =
          object.properties.getProperty<StringProperty>('animationFile');
      if (animationFile != null) {
        data.animationJsonFile = animationFile.value;
      }

      data.name = object.name;
      data.position = Vector2(object.x, object.y);
      spawnData.add(data);
    }
    return spawnData;
  }

  void _addBlockedCell(Vector2 position) {
    final t = posToTile(position);

    int x = t.x.toInt();
    int y = t.y.toInt();
    blockedTiles[x][y] = true;

    _blockedTileList.add(k.Tile(x, y));
  }

  void playerEntered() async {
    game.save();
    if (game.player.parent != null) {
      game.player.removeFromParent();
    }

    tiledmap?.add(game.player);

    if (_reEntryPos.isZero()) {
      return;
    }
    game.player.position = _reEntryPos;
  }

  void _createNpcs() {
    final spawns = _readNpcSpawnPoints(tiledmap!.tileMap);
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
    final spawns = _readEnemySpawns(tiledmap!.tileMap);
    for (final spawnPos in spawns) {
      final enemy = Enemy();
      enemy.position = spawnPos;
      enemies.add(enemy);
      add(enemy);
    }
    return enemies;
  }

  NPC? _isTileBlockedNpc(k.Tile nextTile) {
    try {
      return _npcTiles[nextTile.x.toInt()][nextTile.y.toInt()];
    } catch (e) {
      print('error checking tile');
    }
    return null;
  }

  Function? _getTilePortal(k.Tile nextTile) {
    try {
      return _triggerTiles[nextTile.x.toInt()][nextTile.y.toInt()];
    } catch (e) {
      print('error checking tile');
    }
    return null;
  }

  Direction findPath(Enemy enemy) {
    final map = tiledmap!.tileMap.map;
    final endVec = posToTile(game.player.position);
    final startVec = posToTile(enemy.position);
    final k.Tile end = k.Tile(endVec.x.toInt(), endVec.y.toInt());
    final k.Tile start = k.Tile(startVec.x.toInt(), startVec.y.toInt());
    final playerTile = posToTile(game.player.position);
    final tiles = tilesArroundPosition(playerTile, 6);
    final wallTiles = getBlockedTilesInList(tiles);
    final npcTiles = _npcs.map((npc) {
      final tile = posToTile(npc.npc.position);
      return k.Tile(tile.x.toInt(), tile.y.toInt());
    }).toSet();
    final enemys = enemies.where((other) => other != enemy);
    final enemyTiles = enemys.map((enemy) {
      final tile = posToTile(enemy.position);
      return k.Tile(tile.x.toInt(), tile.y.toInt());
    }).toSet();
    final barrierTiles = Set<k.Tile>.from([...wallTiles, ...npcTiles, ...enemyTiles]).toList();
    final barrierPoints = barrierTiles.map((tile) {
      return math.Point(tile.x, tile.y);
    }).toList();
    try {
      final result = AStarAlgorithm.AStar(
              rows: map.width,
              columns: map.height,
              start: start.toPoint(),
              end: end.toPoint(),
              withDiagonal: false,
              barriers: barrierPoints)
          .findThePath(doneList: (doneList) {});

      if (result.isEmpty) {
        return Direction.none;
      }

      final tilePath = result.map((point) {
        return tileToPos(k.Tile.fromPoint(point));
      }).toList();

      if (tilePath.length > 1) {
        final tile = tilePath[1];
        // prevent from running over player
        if (posToTile(tile) == posToTile(game.player.position)) {
          return Direction.none;
        }

        final tilePoint = k.Tile(tile.x.toInt(), tile.y.toInt());
        final enemyPos = enemy.position;
        final enemyPoint = k.Tile(enemyPos.x.toInt(), enemyPos.y.toInt());
        final direction = directionFromPosToPos(enemyPoint, tilePoint);
        return direction;
      }
    } catch (e) {}

    return Direction.none;
  }

  List<k.Tile> tilesArroundPosition(k.Tile playerTile, int distance) {
    final map = tiledmap!.tileMap.map;
    // get left boundary
    final int farthestTileXLeftAvailable =
        playerTile.x > distance ? playerTile.x.toInt() - distance : 0;
    // get right boundary
    final int farthestTileXRightAvailable = playerTile.x + distance < map.width
        ? playerTile.x.toInt() + distance
        : playerTile.x.toInt() + (map.width - playerTile.x.toInt());
    // get bottom boundary
    final int farthestTileYDownAvailable = playerTile.y + distance < map.height
        ? playerTile.y.toInt() + distance
        : playerTile.y.toInt() + (map.height - playerTile.y.toInt());
    // get top boundary
    final int farthestTileYUpAvailable =
        playerTile.y.toInt() > distance ? playerTile.y.toInt() - distance : 0;

    final List<k.Tile> tiles = [];

    for (int x = farthestTileXLeftAvailable;
        x < farthestTileXRightAvailable;
        x++) {
      for (int y = farthestTileYUpAvailable;
          y < farthestTileYDownAvailable;
          y++) {
        tiles.add(k.Tile(x, y));
      }
    }

    return tiles;
  }

  List<k.Tile> getBlockedTilesInList(List<k.Tile> list) {
    final List<k.Tile> tiles = [];
    for (final tile in list) {
      final pos = k.Tile(tile.x, tile.y);
      if (isTileBlocked(pos)) {
        tiles.add(tile);
      }
    }
    return tiles;
  }

  void clearDebug() {
    for (final square in _squares) {
      square.removeFromParent();
    }
    _squares.clear();
  }

  void drawSquare(Vector2 pos, [PaletteEntry palette = BasicPalette.red]) {
    final square = Square(palette)..position = pos;
    _squares.add(square);
    add(square);
  }

  List<Enemy> getEnemiesWithinRange(int distance) {
    final list = enemies.where((npc) {
      final enemyTile = posToTile(npc.position);
      final playerTile = posToTile(game.player.position);
      final dist = enemyTile.distanceTo(playerTile);
      return dist <= distance;
    }).toList();
    return list;
  }

  void playerBoughtItem(Item item) {
    if (game.player.data.gold < item.cost) {
      final dialog = DialogData();
      dialog.title = 'Oops!';
      dialog.message = 'Sorry, you don\'t have enough gold!';
      game.ref?.read(dialogProvider.notifier).set(dialog);
      game.ref?.read(uiProvider.notifier).set(UIViewDisplayType.dialog);
    } else {
      item.isSelected = false;
      game.player.data.gold -= item.cost;
      game.ref?.read(uiProvider.notifier).set(UIViewDisplayType.game);

      if (item.name == 'Heal') {
        game.player.data.health = game.player.data.maxHealth;
      } else {
        game.player.data.inventory.add(item);
      }

      updateUI();
    }
  }

  void equipArmor(Item item) {
    game.player.armor.isEquipped = false;
    game.player.armor = item;
    item.isEquipped = true;
  }

  void equipWeapon(Item item) {
    game.player.weapon.isEquipped = false;
    game.player.weapon = item;
    item.isEquipped = true;
  }

  void useItem(Item item) {
    switch (item.type) {
      case ItemType.heal:
        break;
      case ItemType.food:
        break;
      case ItemType.weapon:
        equipWeapon(item);
        break;
      case ItemType.armor:
        equipArmor(item);
        break;
      case ItemType.potion:
        game.player.drinkPotion(item);
        final pos = combatTextPositionForEntity(game.player);
        showCombatMessage(pos, '+${item.value}', Colors.lightGreen);
        game.player.data.delete(item);
        break;
      case ItemType.torch:
        break;
      case ItemType.none:
        break;
    }
    updateUI();
  }

  void updateUI() {
    game.ref?.read(healthProvider.notifier).set(game.player.data.health);
    game.ref?.read(goldProvider.notifier).set(game.player.data.gold);
  }

  void showCombatMessage(Vector2 pos, String message, Color color) {
    const fontSize = 16.0;
    final paint = TextPaint(
        style: TextStyle(
            color: color, fontSize: fontSize, fontWeight: FontWeight.bold));
    final text =
        TextComponent(textRenderer: paint, text: message, position: pos);
    final moveUp = MoveEffect.by(
        Vector2(0, -30), EffectController(duration: 2.0), onComplete: () {
      text.removeFromParent();
    });
    text.add(moveUp);
    add(text);

    final foregroundPaint = Paint();
    foregroundPaint.style = PaintingStyle.stroke;
    foregroundPaint.strokeWidth = 0.75;
    foregroundPaint.color = Colors.black;
    final textOutlinePaint = TextPaint(
        style: TextStyle(
            foreground: foregroundPaint,
            fontSize: fontSize,
            fontWeight: FontWeight.bold));
    final textOutline = TextComponent(
        textRenderer: textOutlinePaint, text: message, position: pos);
    final outlineMoveup = MoveEffect.by(
        Vector2(0, -30), EffectController(duration: 2.0), onComplete: () {
      textOutline.removeFromParent();
    });
    textOutline.add(outlineMoveup);
    add(textOutline);
  }

  void playerMoved() {
    if(game.ref?.read(enemiesEnabled) ?? true) {
      enemyCreator.playerMoved();
    }
  }
}
