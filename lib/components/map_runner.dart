import 'dart:async';
import 'dart:math' as math;
import 'package:a_star_algorithm/a_star_algorithm.dart' as a_star;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:karas_quest/components/base_map.dart';
import 'package:karas_quest/components/dungeon_map.dart';
import 'package:karas_quest/components/enemy.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/components/melee_attack_result.dart';
import 'package:karas_quest/components/melee_character.dart';
import 'package:karas_quest/components/npc.dart';
import 'package:karas_quest/components/square.dart';
import 'package:karas_quest/components/turn_system.dart';
import 'package:karas_quest/components/world_map.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/enum/direction.dart';
import 'package:karas_quest/control/enum/item_type.dart';
import 'package:karas_quest/control/enum/ui_view_type.dart';
import 'package:karas_quest/control/json/item.dart';
import 'package:karas_quest/control/json/map_data.dart';
import 'package:karas_quest/control/json/portal.dart';
import 'package:karas_quest/control/json/quest.dart';
import 'package:karas_quest/control/json/shop.dart';
import 'package:karas_quest/control/json/tile.dart' as k;
import 'package:karas_quest/control/provider/dialog_provider.dart';
import 'package:karas_quest/control/provider/gold_provider.dart';
import 'package:karas_quest/control/provider/health_provider.dart';
import 'package:karas_quest/control/provider/quest_giver.dart';
import 'package:karas_quest/control/provider/shop_item_provider.dart';
import 'package:karas_quest/control/provider/shop_provider.dart';
import 'package:karas_quest/control/provider/ui_provider.dart';
import 'package:karas_quest/screens/view/debug/enemies_enabled_provider.dart';

class MapRunner extends World with HasGameRef<MainGame>, TapCallbacks, PortalDelegate, OnLoadFinishedDelegate {
  MapData mapData = MapData();
  BaseMap? map;
  
  final List<Square> _squares = [];
  final _aggroDistance = 6;
  bool listenToInput = true;
  late final TurnSystem turnSystem;
  final List<Enemy> _enemiesToMove = [];
  bool shouldContinue = false; // player continuos movement
  Direction lastDirection = Direction.none;

  // serializable properties
  List<Enemy> enemies = [];
  Vector2 _playerPos = Vector2.zero();

  MapRunner();

  MapRunner.fromMapData(MapData map) {
    mapData = map;
  }

  MapData toMapData() {
    sync();
    return map!.mapData;
  }

  void sync() {
    // if this level hasnt been loaded yet, enemies will be empty. 
    // if mapData has enemies, dont override them
    if (enemies.isNotEmpty) {
      map!.mapData.enemies = enemies.map((enemy) {
        return enemy.data;
      }).toList();
    }
    map!.mapData.playerTile = posToTile(_playerPos);
  }

  @override
  void onMount() {
    super.onMount();
    playerEntered();
    
    game.uiFinishedLoading();
  }

  @override
  FutureOr<void> onLoad() async {
    if(mapData.isGenerated) {
      map = DungeonMap.fromMapData(mapData);
    } else {
      map = WorldMap.fromMapData(mapData);
    }
    add(map!);
    map?.portalDelegate = this;

    turnSystem = TurnSystem(mapRunner: this, playerFinishedCallback: () {});
    turnSystem.updateState(TurnSystemState.player);
    updateQuestIcons();
    updateUI();
  }

  @override
  Future<void> onLoadFinished() async {

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
      pos.y -= kTileSize;
    }
    if (entity.position.x == game.player.position.x) {
      pos.x += kTileSize;
    }
    return pos;
  }

  void enemyAttackPlayer(Enemy enemy, Direction playerDirection) {
    final pos = game.player.position.clone();
    if(enemy.position.y == game.player.position.y) {
      pos.y -= kTileSize;
    }

    if(!enemy.attemptAttack()) {
      enemyMissed(enemy, playerDirection);
      return;
    }

    final damage = enemy.weapon.value;
    if (enemy.position.x == game.player.position.x) {
      pos.x += kTileSize;
    }

    enemy.playAttackDirectionAnim(playerDirection, () {
      final attackResult = game.player.takeHit(damage, () {
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
        game.onPlayerDied();
      });

      final damageString = attackResult.value == 0 ? '' : '-${attackResult.value}';
      final resultString = attackResult.result == MeleeAttackResult.success ? '' : attackResult.result.name;  
      showCombatMessage(pos,'$resultString $damageString', const Color.fromARGB(249, 255, 96, 96));
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
      pos.y -= kTileSize;
    }
    if (enemy.position.x == game.player.position.x) {
      pos.x -= kTileSize + kTileSize/2;
    }
    
    game.player.playAttackDirectionAnim(direction, () {
      final damageDone = enemy.takeHit(game.player.weapon.value, () {
        game.mapRunner!.turnSystem.updateState(TurnSystemState.playerFinished);
      }, () {
        game.player.data.gold += enemy.data.gold;
        game.player.data.experience += enemy.experienceYield;
        updateUI();
        enemy.removeFromParent();
        enemies.removeWhere((other) => other == enemy);
        game.mapRunner!.turnSystem.updateState(TurnSystemState.playerFinished);
      });
        final damageString = damageDone.value == 0 ? '' : '-${damageDone.value}';
        final resultString = damageDone.result == MeleeAttackResult.success ? '' : damageDone.result.name;
        showCombatMessage(pos, '$resultString $damageString',const Color.fromARGB(250, 255, 255, 255));
      });
  }
 
  void playerMissed(MeleeCharacter enemy, Direction direction) {
    final pos = enemy.position.clone();
    if(enemy.position.y == game.player.position.y) {
      pos.y -= kTileSize;
    }
    if (enemy.position.x == game.player.position.x) {
      pos.x -= kTileSize;
    }
    game.player.playAttackDirectionAnim(direction, () {
      game.mapRunner!.turnSystem.updateState(TurnSystemState.playerFinished);
      showCombatMessage(pos, 'miss',const Color.fromARGB(250, 255, 255, 255));
    });
  }

  void enemyMissed(MeleeCharacter enemy, Direction direction) {
    final pos = game.player.position.clone();
    if(enemy.position.y == game.player.position.y) {
      pos.y -= kTileSize;
    }
    if (enemy.position.x == game.player.position.x) {
      pos.x += kTileSize;
    }
    enemy.playAttackDirectionAnim(direction, () {
      showCombatMessage(pos,'miss', const Color.fromARGB(249, 255, 96, 96));
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
    final playerTile = posToTile(game.player.position);
    final nextTile = getNextTile(direction, playerTile);
    final npc = _isTileBlockedNpc(nextTile);
    final portal = _getTilePortal(nextTile);
    if (npc != null) {
        interactWithNpc(npc);
        return false;
    }
    _playerPos = Vector2(game.player.position.x, game.player.position.y);
    if(portal != null) {
      shouldContinue = false;
      portal();
    }
  
    return !isTileBlocked(nextTile);
  }

  Future<void> interactWithNpc(NPC npc) async {
    final questsAvailable = await npc.questsAvailable();
    postGameEvent('talk_to', npc.npc.name);
    if(questsAvailable.isNotEmpty) {
      game.ref?.read(questGiverSelectedQuest.notifier).set(questsAvailable.first);
      showQuestDialog(questsAvailable);
      return;
    }
      
    if (npc.npc.shopJsonFile.isNotEmpty) {
      showShop(npc);
      return;
    }
    showDialog(npc);
  }

  Future<void> showDialog(NPC npc) async {
    final dialog = DialogData();
    dialog.title = npc.npc.name;
    dialog.message = npc.npc.speech;
    game.ref?.read(dialogProvider.notifier).set(dialog);
    game.ref?.read(uiProvider.notifier).set(UIViewDisplayType.dialog);
  }

  void showQuestDialog(List<Quest> quests) {
    game.ref?.read(questGiver.notifier).set([...quests]);
    game.ref?.read(uiProvider.notifier).set(UIViewDisplayType.questGiver);
  }

  Future<void> showShop(NPC npc) async {
    final json = await game.assets.readJson(npc.npc.shopJsonFile);
    final shop = Shop.fromJson(json);
    final items = shop.items;
    if(items.isEmpty) {
      return;
    }
    game.ref?.read(shopProvider.notifier).set(shop);
    final firstItem = shop.items.first;
    firstItem.isSelected = true;
    game.ref?.read(shopItemProvider.notifier).set(firstItem);
    game.ref?.read(uiProvider.notifier).set(UIViewDisplayType.shop);
  }

  bool isTileBlocked(k.Tile pos) {
    try {
      return map!.tiles[pos.x][pos.y];
    } on Exception catch (e) {
      debugPrint('error checking if tile is blocked at: ${pos.x}, ${pos.y}');
      debugPrint(e.toString());
    }
    return false;
  }

  void steppedOnTile(k.Tile tile) {
    if (game.currentSpeechBubble != null) {
      game.currentSpeechBubble!.removeFromParent();
      game.currentSpeechBubble = null;
    }
  }

  @override
  Future<void> portalEntered(Portal portal) async {
    shouldContinue = false;
    await game.mapLoader.pushWorld(portal.mapData);
  }

  Future<void> playerEntered() async {
    map?.playerEntered();
    // game.save();

    if (_playerPos.isZero()) {
      return;
    }
    game.player.position = _playerPos;
  }

  NPC? _isTileBlockedNpc(k.Tile nextTile) {
    try {
      return map?.npcTiles[nextTile.x][nextTile.y];
    } on Exception catch (e) {
      debugPrint('error checking tile $e');
    }
    return null;
  }

  Function? _getTilePortal(k.Tile nextTile) {
    try {
      return map?.triggerTiles[nextTile.x][nextTile.y];
    } on Exception catch (e) {
      debugPrint('error checking tile $e');
    }
    return null;
  }

  Direction findPath(Enemy enemy) {
    final end = posToTile(game.player.position);
    final start = posToTile(enemy.position);
    final playerTile = posToTile(game.player.position);
    final width = map!.mapData.width;
    final height = map!.mapData.height;
    final tiles = tilesArroundPosition(playerTile, 6);
    final wallTiles = getBlockedTilesInList(tiles);
    final npcTiles = map!.npcs.map((npc) {
      return posToTile(npc.npc.position);
    }).toSet();
    final enemys = enemies.where((other) => other != enemy);
    final enemyTiles = enemys.map((enemy) {
      return posToTile(enemy.position);
    }).toSet();
    final barrierTiles = {...wallTiles, ...npcTiles, ...enemyTiles}.toList();
    final barrierPoints = barrierTiles.map((tile) {
      return math.Point(tile.x, tile.y);
    }).toList();
    try {
      final result = a_star.AStar(
              rows: width,
              columns: height,
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
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    return Direction.none;
  }

  List<k.Tile> tilesArroundPosition(k.Tile playerTile, int distance) {
    // get left boundary
    final width = game.mapRunner?.map!.mapData.width ?? 0;
    final height = game.mapRunner?.map!.mapData.height ?? 0;
    final farthestTileXLeftAvailable =
        playerTile.x > distance ? playerTile.x - distance : 0;
    // get right boundary
    final farthestTileXRightAvailable = playerTile.x + distance < width
        ? playerTile.x + distance
        : playerTile.x + (width - playerTile.x);
    // get bottom boundary
    final farthestTileYDownAvailable = playerTile.y + distance < height
        ? playerTile.y + distance
        : playerTile.y + (height - playerTile.y);
    // get top boundary
    final farthestTileYUpAvailable =
        playerTile.y > distance ? playerTile.y - distance : 0;

    final tiles = <k.Tile>[];

    for (var x = farthestTileXLeftAvailable;
        x < farthestTileXRightAvailable;
        x++) {
      for (var y = farthestTileYUpAvailable;
          y < farthestTileYDownAvailable;
          y++) {
        tiles.add(k.Tile(x, y));
      }
    }

    return tiles;
  }

  List<k.Tile> getBlockedTilesInList(List<k.Tile> list) {
    final tiles = <k.Tile>[];
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
      dialog.message = "Sorry, you don't have enough gold!";
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
      postGameEvent('buy', item.name);
      updateUI();
    }
  }

  void useItem(Item item) {
    switch (item.type) {
      case ItemType.heal:
        break;
      case ItemType.food:
        break;
      case ItemType.weapon:
        game.player.equipWeapon(item);
        break;
      case ItemType.armor:
        game.player.equipArmor(item);
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
    const fontSize = 8.0;
    final paint = TextPaint(
        style: TextStyle(
            color: color, fontSize: fontSize, fontWeight: FontWeight.bold));
    final text =
        TextComponent(textRenderer: paint, text: message, position: pos);
    final moveUp = MoveEffect.by(Vector2(0, -30), EffectController(duration: 2.0), onComplete: text.removeFromParent);
    text.add(moveUp);
    add(text);

    final foregroundPaint = Paint();
    foregroundPaint.style = PaintingStyle.stroke;
    foregroundPaint.strokeWidth = 0.3;
    foregroundPaint.color = Colors.black;
    final textOutlinePaint = TextPaint(
        style: TextStyle(
            foreground: foregroundPaint,
            fontSize: fontSize,
            fontWeight: FontWeight.bold));
    final textOutline = TextComponent(
        textRenderer: textOutlinePaint, text: message, position: pos);
    final outlineMoveup = MoveEffect.by(
        Vector2(0, -30), EffectController(duration: 2.0), onComplete: textOutline.removeFromParent);
    textOutline.add(outlineMoveup);
    add(textOutline);
  }

  void playerMoved() {
    if(game.ref?.read(enemiesEnabled) ?? true) {
      map?.enemyCreator?.createEnemy();
    }
  }

  void postGameEvent(String event, String value) {
    game.onGameEvent(event, value);

    if(event == 'talk_to') {
      updateQuestIcons();
    }
  }

  Future<void> updateQuestIcons() async {
    // for(final npc in _npcs) {
    //   final quests = await npc.questsAvailable();
    //   npc.setHasQuestIcon(shouldShow: quests.isNotEmpty);
    // }
  }
}
