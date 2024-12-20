import 'dart:convert';
import 'dart:io';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karas_quest/components/map_runner.dart';
import 'package:karas_quest/components/overworld_navigator.dart';
import 'package:karas_quest/components/player_component.dart';
import 'package:karas_quest/control/enum/debug_command.dart';
import 'package:karas_quest/control/enum/direction.dart';
import 'package:karas_quest/control/enum/item_type.dart';
import 'package:karas_quest/control/enum/ui_view_type.dart';
import 'package:karas_quest/control/json/quest.dart';
import 'package:karas_quest/control/json/save_file.dart';
import 'package:karas_quest/control/objects/game_event_listener.dart';
import 'package:karas_quest/control/objects/quest_manager.dart';
import 'package:karas_quest/control/provider/inventory_item_provider.dart';
import 'package:karas_quest/control/provider/inventory_provider.dart';
import 'package:karas_quest/control/provider/quest_provider.dart';
import 'package:karas_quest/control/provider/ui_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainGame extends FlameGame with TapDetector {
  PlayerComponent player = PlayerComponent();
  MapRunner? mapRunner;
  final mapLoader = MapLoader();
  Component? currentSpeechBubble;
  WidgetRef? ref;
  static late MainGame instance;
  bool isMoveKeyDown = false;
  TextComponent debugLabel = TextComponent();
  late final gameEventListener = GameEventListener(this);
  SaveFile saveFile = SaveFile();
  late QuestManager questManager;
  bool isNewGame = true;

  MainGame({required this.isNewGame});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    instance = this;
    add(mapLoader);
    final debugLabel = TextComponent();
    debugLabel.position = Vector2(size.x / 2, 100);
    debugLabel.text = '';
    debugLabel.textRenderer = TextPaint(style: const TextStyle(color: Colors.red));
    debugLabel.priority = double.maxFinite.toInt();
    debugLabel.anchor = Anchor.center;
    add(debugLabel);

    if(isNewGame) {
      loadNewGame();
    } else {
      loadSavedGame();
    }
  }

  void uiFinishedLoading() {
    if(ref != null && ref!.context.mounted) {
      ref?.read(inventoryProvider.notifier).set(player.data);
      ref?.read(inventoryItemProvider.notifier).set(player.data.inventory.first);
      ref?.read(questListProvider.notifier).set(saveFile.activeQuests);
      ref?.read(uiProvider.notifier).set(UIViewDisplayType.game);
    }
  }

  Future<void> save() async {
    mapLoader.save(saveFile); 
    saveFile.playerData = player.data;
    final saveMap = saveFile.toMap();
    final jsonString = jsonEncode(saveMap);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('save_file', jsonString);
    final directory = await getDownloadsDirectory();
    final filepath = '${directory?.path}/game.json';
    final file = File(filepath);
    await file.writeAsString(jsonString);
  }

  Future<void> loadNewGame() async {
    final defaultJson = await rootBundle.loadString('assets/json/savefile.json');

    final map = jsonDecode(defaultJson) as Map<String, dynamic>? ?? {};
    saveFile = SaveFile.fromMap(map);

    questManager = QuestManager(this);
    player.data = saveFile.playerData;
    final firstItem = player.data.inventory.first;
    firstItem.isSelected = true;
    final weapon = player.data.inventory.where((item) => item.isEquipped && item.type == ItemType.weapon).firstOrNull;
    if (weapon != null) {
      player.weapon = weapon;
    }

    mapLoader.initFromSaveFile(saveFile);

    // mapRunner?.equipWeapon(player.weapon);
    // mapRunner?.equipArmor(player.armor);
    // if(ref != null && ref!.context.mounted) {
    //   ref?.read(inventoryProvider.notifier).set(player.data);
    //   ref?.read(inventoryItemProvider.notifier).set(firstItem);
    //   ref?.read(questListProvider.notifier).set(saveFile.activeQuests);
    // }
    // mapRunner?.initFromMap(map);
  }

  Future<void> loadSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('save_file') ?? '{}';
    final map = jsonDecode(jsonString) as Map<String, dynamic>? ?? {};
    saveFile = SaveFile.fromMap(map);
    if(saveFile.isFreshGame) {
      loadNewGame();
      return;
    }
    questManager = QuestManager(this);
    player.data = saveFile.playerData;
    final firstItem = player.data.inventory.first;
    firstItem.isSelected = true;
    final weapon = player.data.inventory.where((item) => item.isEquipped && item.type == ItemType.weapon).firstOrNull;
    if (weapon != null) {
      player.weapon = weapon;
    }

    mapLoader.initFromSaveFile(saveFile);

    // questManager = QuestManager(this);
    // player.data = saveFile.playerData;
    // final firstItem = player.data.inventory.first;
    // firstItem.isSelected = true;
    // final weapon = player.data.inventory.where((item) => item.isEquipped && item.type == ItemType.weapon).firstOrNull;
    // if (weapon != null) {
    //   player.weapon = weapon;
    // }
    // mapRunner?.equipWeapon(player.weapon);
    // mapRunner?.equipArmor(player.armor);
    // if(ref != null && ref!.context.mounted) {
    //   ref?.read(inventoryProvider.notifier).set(player.data);
    //   ref?.read(inventoryItemProvider.notifier).set(firstItem);
    //   ref?.read(questListProvider.notifier).set(saveFile.activeQuests);
    // }
    // mapRunner?.initFromMap(map);
  }

  void directionDown(Direction direction) {
    mapRunner?.directionPressed(direction);
    mapRunner?.shouldContinue = true;
  }

  void directionUp(Direction direction) {
    mapRunner?.shouldContinue = false;
  }

  void directionPressed(Direction direction) {
    if (mapRunner != null) {
      mapRunner!.directionPressed(direction);
    }
  }

  void command(String text, BuildContext context) {
    ref?.read(uiProvider.notifier).set(UIViewDisplayType.game);

    final command = parseCommand(text);
    switch(command.command) {
      case DebugCommand.none:
      return;
      case DebugCommand.reset:
        Navigator.pop(context);
        return;
      case DebugCommand.heal:
        player.data.heal(int.parse(command.argument));
        mapRunner?.updateUI();
        return;
      case DebugCommand.reload:
        Navigator.pop(context);
        return;
      case DebugCommand.sethp:
        player.data.health = int.parse(command.argument);
        mapRunner?.updateUI();
        return;
      case DebugCommand.setstam:
        player.data.stam = int.parse(command.argument);
        mapRunner?.updateUI();
        return;
      case DebugCommand.setstr:
        player.data.str = int.parse(command.argument);
        save();
        return;
      case DebugCommand.map:
        mapLoader.pushWorld(command.argument);
        return;
      case DebugCommand.save:
      // toMap
        save();
    }
  }

  ({String command, String argument}) getCommandAndParamStrings(String input) {
    final strings = input.split(' ');
    if(strings.length == 1) {
      return (command: strings.first, argument: '');
    } else if(strings.length == 2) {
      return (command: strings.first, argument: strings.last);
    }
    return (command: '', argument: '');
  }

  ({DebugCommand command, String argument}) parseCommand(String input) {
    final commandData = getCommandAndParamStrings(input);
    final commands = DebugCommand.values.where((command) { 
      final match = command.name == commandData.command;
      return match;
  }).toList();
    if(commands.isEmpty) {
      return (command:DebugCommand.none, argument: '');
    }
    return (command:commands.first, argument: commandData.argument);
  }

  void onGameEvent(String event, String target) {
    gameEventListener.onEvent(event, target, ref);
    save();
  }

  Future<void> onPlayerDied() async {
    final map = <String, dynamic>{};
    saveFile = SaveFile.fromMap(map);
    player.data = saveFile.playerData;
    final firstItem = player.data.inventory.first;
    firstItem.isSelected = true;
    ref?.read(inventoryProvider.notifier).set(player.data);
    ref?.read(inventoryItemProvider.notifier).set(firstItem);

    final weapon = player.data.inventory.where((item) => item.isEquipped && item.type == ItemType.weapon).firstOrNull;
    if (weapon != null) {
      player.weapon = weapon;
    }

    final quest = Quest();
    await quest.loadDefaultQuest();
    saveFile.activeQuests.add(quest);
    ref?.read(questListProvider.notifier).set(saveFile.activeQuests);

    save();
  }
}
