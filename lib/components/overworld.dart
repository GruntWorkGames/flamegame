import 'dart:async';
import 'package:a_star_algorithm/a_star_algorithm.dart' as AStarAlgorithm;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flame_game/components/enemy.dart';
import 'package:flame_game/components/npc.dart';
import 'package:flame_game/components/square.dart';
import 'package:flame_game/components/turn_system.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/control/enum/item_type.dart';
import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/json/item.dart';
import 'package:flame_game/control/json/shop.dart';
import 'package:flame_game/control/portal.dart';
import 'package:flame_game/control/provider/dialog_provider.dart';
import 'package:flame_game/control/provider/gold_provider.dart';
import 'package:flame_game/control/provider/healthProvider.dart';
import 'package:flame_game/control/provider/shop_item_provider.dart';
import 'package:flame_game/control/provider/shop_provider.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/components/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';
import 'dart:math' as math;

class Overworld extends World with HasGameRef<MainGame>, TapCallbacks {
  List<List<dynamic>> _blockedTiles = [];
  List<List<dynamic>> _triggerTiles = [];
  List<List<dynamic>> _npcTiles = [];
  List<List<dynamic>> _enemyTiles = [];
  List<Enemy> _enemies = [];
  List<NPC> _npcs = [];
  bool listenToInput = false;
  String _mapfile = '';
  Vector2 _reEntryPos = Vector2.zero();
  TiledComponent? _tiledmap;
  // final enemyCreator = EnemyCreator();
  late final TurnSystem turnSystem;
  List<math.Point<int>> _blockedTileList = [];
  List<Enemy> _enemiesToMove = [];
  final List<Square> _squares = [];
  double zoomFactor = 2.4;
  final _aggroDistance = 8;

  Overworld(this._mapfile);

  @override
  void onMount() {
    super.onMount();
    playerEntered();
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
    turnSystem = TurnSystem(overworld: this, playerFinishedCallback: () {});
    
    game.camera.follow(game.player);
    turnSystem.updateState(TurnSystemState.player);
    game.ref.read(uiProvider.notifier).set(UIViewDisplayType.game);
    game.camera.viewfinder.zoom = zoomFactor;

    game.player.data.tilePosition = posToTile(game.player.position);
    final isSavedTileZero = game.player.data.tilePosition.isZero();
    final isPlayerAtZero = game.player.position.isZero();
    final isMapMatch = game.player.data.mapfile == _mapfile;
    // new game?
    if(!isSavedTileZero && isPlayerAtZero && isMapMatch) {
      game.player.position = tileToPos(game.player.data.tilePosition);
    } else {
      game.player.position = _readSpawnPoint(_tiledmap!.tileMap);
    }
    
    game.player.data.mapfile = _mapfile;
    game.player.data.tilePosition = posToTile(game.player.position);
    updateUI();
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

  void enemyAttackPlayer(Enemy enemy, Direction playerDirection) {
    enemy.playAttackDirectionAnim(playerDirection, () {
      game.player.takeHit(enemy.weapon.value, () {
        game.ref.read(healthProvider.notifier).set(game.player.data.health);
        enemy.onMoveCompleted(enemy.position);
      }, () {
        // on death callback
        game.ref.read(healthProvider.notifier).set(game.player.data.health);
        game.player.removeFromParent();

        final dialog = DialogData();
        dialog.title = 'You have died';
        dialog.message = 'Press here to restart';
        game.ref.read(dialogProvider.notifier).set(dialog);
        game.ref.read(uiProvider.notifier).set(UIViewDisplayType.gameOver);
      });
      showCombatMessage(game.player.position.clone(), '-${enemy.weapon.value}', Color.fromARGB(250, 250, 0, 0));
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
  }

  void fightDirectionPressed(Enemy enemy, Direction direction) {
    if (!listenToInput) {
      return;
    }
    game.player.playAttackDirectionAnim(direction, () {
      enemy.takeHit(game.player.weapon.value, () {
        game.overworld!.turnSystem.updateState(TurnSystemState.playerFinished);
      }, () {
        game.player.data.gold += enemy.data.gold;
        updateUI();
        enemy.removeFromParent();
        _enemies.removeWhere((other) => other == enemy);
        game.overworld!.turnSystem.updateState(TurnSystemState.playerFinished);
      });
      showCombatMessage(enemy.position.clone(), '-${game.player.weapon.value}', Color.fromARGB(250, 250, 250, 250));
    });
  }

  Enemy? getEnemyInDirection(Direction direction) {
    final playerTile = posToTile(game.player.position);
    final nextTile = getNextTile(direction, playerTile);
    for (final enemy in _enemies) {
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
    game.ref.read(dialogProvider.notifier).set(dialog);
    game.ref.read(uiProvider.notifier).set(UIViewDisplayType.dialog);
  }

  void showShop(NPC npc) async {
    final json = await game.assets.readJson(npc.npc.shopJsonFile);
    final shop = Shop.fromJson(json);
    game.ref.read(shopProvider.notifier).set(shop);
    final firstItem = shop.items.first;
    firstItem.isSelected = true;
    game.ref.read(shopItemProvider.notifier).set(firstItem);
    game.ref.read(uiProvider.notifier).set(UIViewDisplayType.shop);
  }

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
    final tilePos = posToTile(Vector2(exit.x, exit.y));
    _triggerTiles[tilePos.x.toInt()][tilePos.y.toInt()] = func;
  }

  Vector2 _readSpawnPoint(RenderableTiledMap tileMap) {
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
    _blockedTiles[x][y] = true;

    _blockedTileList.add(math.Point<int>(x, y));
  }

  void playerEntered() async {
    game.save();
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
      _npcs.add(npc);
      final tile = posToTile(npc.position);
      _npcTiles[tile.x.toInt()][tile.y.toInt()] = npc;
    }
  }

  List<Enemy> _createEnemies(RenderableTiledMap tileMap) {
    final List<Enemy> enemies = [];
    final spawns = _readEnemySpawns(_tiledmap!.tileMap);
    for (final spawnPos in spawns) {
      final enemy = Enemy();
      enemy.position = spawnPos;
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

  Direction findPath(Enemy enemy) {
    final map = _tiledmap!.tileMap.map;
    final endVec = posToTile(game.player.position);
    final startVec = posToTile(enemy.position);
    final math.Point<int> end = math.Point(endVec.x.toInt(), endVec.y.toInt());
    final math.Point<int> start =
        math.Point(startVec.x.toInt(), startVec.y.toInt());
    final playerTile = posToTile(game.player.position);
    final tiles = tilesArroundPosition(playerTile, 6);
    final wallTiles = getBlockedTilesInList(tiles);
    final npcTiles = _npcs.map((npc) {
      final tile = posToTile(npc.npc.position);
      return math.Point<int>(tile.x.toInt(), tile.y.toInt());
    }).toSet();
    final enemys = _enemies.where((other) => other != enemy);
    final enemyTiles = enemys.map((enemy) {
      final tile = posToTile(enemy.position);
      return math.Point<int>(tile.x.toInt(), tile.y.toInt());
    }).toSet();
    final barriers =
        Set<math.Point<int>>.from([...wallTiles, ...npcTiles, ...enemyTiles])
            .toList();
    final result = AStarAlgorithm.AStar(
            rows: map.width,
            columns: map.height,
            start: start,
            end: end,
            withDiagonal: false,
            barriers: barriers)
        .findThePath(doneList: (doneList) {});

    if (result.isEmpty) {
      return Direction.none;
    }

    final tilePath = result.map((point) {
      return tileToPos(Vector2(point.x.toDouble(), point.y.toDouble()));
    }).toList();

    if (tilePath.length > 1) {
      final tile = tilePath[1];
      // prevent from running over player
      if (posToTile(tile) == posToTile(game.player.position)) {
        return Direction.none;
      }

      final direction = directionFromPosToPos(enemy.position, tile);
      return direction;
    }

    return Direction.none;
  }

  List<math.Point<int>> tilesArroundPosition(Vector2 playerTile, int distance) {
    final map = _tiledmap!.tileMap.map;
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

    final List<math.Point<int>> tiles = [];

    for (int x = farthestTileXLeftAvailable;
        x < farthestTileXRightAvailable;
        x++) {
      for (int y = farthestTileYUpAvailable;
          y < farthestTileYDownAvailable;
          y++) {
        tiles.add(math.Point<int>(x, y));
      }
    }

    return tiles;
  }

  List<math.Point<int>> getBlockedTilesInList(List<math.Point<int>> list) {
    final List<math.Point<int>> tiles = [];
    for (final tile in list) {
      final pos = Vector2(tile.x.toDouble(), tile.y.toDouble());
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
    final list = _enemies.where((npc) {
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
      game.ref.read(dialogProvider.notifier).set(dialog);
      game.ref.read(uiProvider.notifier).set(UIViewDisplayType.dialog);
    } else {
      item.isSelected = false;
      game.player.data.gold -= item.cost;
      game.ref.read(uiProvider.notifier).set(UIViewDisplayType.game);

      if (item.name == 'Heal') {
        game.player.data.health = game.player.data.maxHealth;
      } else {
        game.player.data.inventory.add(item);
      }

      updateUI();
    }
  }

  void equipArmor(Item item) {}

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
    game.ref.read(healthProvider.notifier).set(game.player.data.health);
    game.ref.read(goldProvider.notifier).set(game.player.data.gold);
  }

  void showCombatMessage(Vector2 pos, String message, Color color) {
    final paint = TextPaint(style: TextStyle(color: color, fontSize: 12));
    final text = TextComponent(textRenderer: paint, text: message, position: pos);
    final moveUp = MoveEffect.by(Vector2(0,-30), EffectController(duration: 2.0), onComplete: (){
      text.removeFromParent();
    });
    text.add(moveUp);
    add(text);
  }
}
