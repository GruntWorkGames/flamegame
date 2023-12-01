import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/control/enum/item_type.dart';
import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/json/inventory.dart';
import 'package:flame_game/control/overworld_navigator.dart';
import 'package:flame_game/control/provider/inventory_item_provider.dart';
import 'package:flame_game/control/provider/inventory_provider.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/components/overworld.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainGame extends FlameGame with TapDetector {
  MeleeCharacter player = MeleeCharacter();
  Overworld? overworld;
  final overworldNavigator = OverworldNavigator();
  Component? currentSpeechBubble;
  late WidgetRef ref;
  static late MainGame instance;
  Inventory inventory = Inventory();

  @override
  Future<void> onLoad() async {
    add(overworldNavigator);
    instance = this;
    overworldNavigator.loadMainWorld();
    _buildInventory();

    // final fps = FpsTextComponent();
    // fps.position = Vector2(25, size.y - 50);
    // add(fps);
  }

  void _buildInventory() async {
    final inventoryJson = await assets.readJson('json/inventory.json');
    inventory = Inventory.fromJson(inventoryJson);
    final firstItem = inventory.items.first;
    firstItem.isSelected = true;
    ref.read(inventoryProvider.notifier).set(inventory);
    ref.read(inventoryItemProvider.notifier).set(firstItem);
    final weapon = inventory.items.where((item) => item.isEquipped && item.type == ItemType.weapon).firstOrNull;
    if(weapon != null) {
      player.weapon = weapon;
    }
  }

  @override
  void onTap() {
    final state = ref.read(uiProvider);
    if (state == UIViewDisplayType.dialog || state == UIViewDisplayType.shop) {
      ref.read(uiProvider.notifier).set(UIViewDisplayType.game);
    }
    
    // if(state == UIViewDisplayType.game) { 
    //   final items = ref.read(inventoryProvider).items;
    //   if(items.isNotEmpty){
    //     ref.read(inventoryItemProvider.notifier).set(items.first);
    //   }
    // final firstItem = inventory.items.first;
    // firstItem.isSelected = true;
    // ref.read(inventoryItemProvider.notifier).set(firstItem);
    //   ref.read(uiProvider.notifier).set(UIViewDisplayType.inventory);
    // }

    // if(state == UIViewDisplayType.inventory) {
    //   ref.read(uiProvider.notifier).set(UIViewDisplayType.game);
    // }


    super.onTap();
  }

  void directionPressed(Direction direction) {
    if (overworld != null) {
      overworld!.directionPressed(direction);
    }
  }
}
