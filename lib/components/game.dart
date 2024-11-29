import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flame_game/components/map_runner.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/components/overworld_navigator.dart';
import 'package:flame_game/components/player_component.dart';
import 'package:flame_game/control/enum/debug_command.dart';
import 'package:flame_game/control/enum/direction.dart';
import 'package:flame_game/control/enum/item_type.dart';
import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/json/quest.dart';
import 'package:flame_game/control/json/save_file.dart';
import 'package:flame_game/control/objects/game_event_listener.dart';
import 'package:flame_game/control/provider/inventory_item_provider.dart';
import 'package:flame_game/control/provider/inventory_provider.dart';
import 'package:flame_game/control/provider/quest_provider.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainGame extends FlameGame with TapDetector {
  PlayerComponent player = PlayerComponent();
  MapRunner? mapRunner;
  final overworldNavigator = OverworldNavigator();
  Component? currentSpeechBubble;
  WidgetRef? ref;
  static late MainGame instance;
  bool isMoveKeyDown = false;
  TextComponent debugLabel = TextComponent();
  late final gameEventListener = GameEventListener(this, player.data);
  SaveFile saveFile = SaveFile();
  List<Quest> quests = <Quest>[];

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(overworldNavigator);
    instance = this;
    await overworldNavigator.pushWorld(player.data.mapfile);
    await loadSavedPlayerData();
    mapRunner?.equipWeapon(player.weapon);
    mapRunner?.equipArmor(player.armor);

    final debugLabel = TextComponent();
    debugLabel.position = Vector2(size.x / 2, 100);
    debugLabel.text = '';
    debugLabel.textRenderer = TextPaint(style: const TextStyle(color: Colors.red));
    debugLabel.priority = double.maxFinite.toInt();
    debugLabel.anchor = Anchor.center;
    add(debugLabel);
  }

  Future<void> save() async {
    final jsonString = jsonEncode(saveFile.toMap());
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('save_file', jsonString);
  }

  Future<void> loadSavedPlayerData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    final jsonString = prefs.getString('save_file') ?? '{}';
    final isNewCharacter = jsonString == '{}';
    final map = jsonDecode(jsonString) as Map<String, dynamic>? ?? {};
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

    if(isNewCharacter) {
      final quest = Quest();
      await quest.loadDefaultQuest();
      player.data.quests.add(quest);
    }
    ref?.read(questListProvider.notifier).set(player.data.quests);
  }

  @override
  void onTap() {
    ref?.read(uiProvider.notifier).set(UIViewDisplayType.game);
    // ref.read(screenTransitionState.notifier).set(true);
    super.onTap();
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
        overworldNavigator.loadNewGame();
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
        overworldNavigator.pushWorld(command.argument);
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

  void playerCompletedQuest(Quest quest) {
    quest.isComplete = true;
    player.data.completedQuests.add(quest);
    player.data.quests.remove(quest);
    ref?.read(questListProvider.notifier).set([...player.data.quests]);
    save();
  }
}
