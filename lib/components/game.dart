import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/control/enum/item_type.dart';
import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/json/character_data.dart';
import 'package:flame_game/components/overworld_navigator.dart';
import 'package:flame_game/control/provider/inventory_item_provider.dart';
import 'package:flame_game/control/provider/inventory_provider.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/components/overworld.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainGame extends FlameGame with TapDetector {
  PlayerComponent player = PlayerComponent();
  Overworld? overworld;
  final overworldNavigator = OverworldNavigator();
  Component? currentSpeechBubble;
  late WidgetRef ref;
  static late MainGame instance;

  @override
  Future<void> onLoad() async {
    add(overworldNavigator);
    instance = this;
    await load();
    // overworldNavigator.loadMainWorld();
    overworldNavigator.loadWorld(player.data.mapfile);
    
    // final fps = FpsTextComponent();
    // fps.position = Vector2(25, size.y - 50);
    // add(fps);
  }

  void save() async {
    final jsonString = jsonEncode(player.data.toJson());
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('player', jsonString);
  }

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('player') ?? '{}';
    final json = jsonDecode(jsonString);
    player.data = CharacterData.fromJson(json);
    final firstItem = player.data.inventory.first;
    firstItem.isSelected = true;
    ref.read(inventoryProvider.notifier).set(player.data);
    ref.read(inventoryItemProvider.notifier).set(firstItem);
    final weapon = player.data.inventory
        .where((item) => item.isEquipped && item.type == ItemType.weapon)
        .firstOrNull;
    if (weapon != null) {
      player.weapon = weapon;
    }
  }

  @override
  void onTap() {
    final state = ref.read(uiProvider);
    if (state == UIViewDisplayType.dialog || state == UIViewDisplayType.shop || state == UIViewDisplayType.inventory) {
      ref.read(uiProvider.notifier).set(UIViewDisplayType.game);
    }

    super.onTap();
  }

  void directionPressed(Direction direction) {
    if (overworld != null) {
      overworld!.directionPressed(direction);
    }
  }
}
