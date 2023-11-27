import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/components/ui.dart';
import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/json/shop.dart';
import 'package:flame_game/control/overworld_navigator.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/components/main_menu.dart';
import 'package:flame_game/screens/components/overworld.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainGame extends FlameGame with TapDetector {
  MeleeCharacter player = MeleeCharacter();
  Overworld? overworld;
  final overworldNavigator = OverworldNavigator();
  final ui = UI.instance;
  Component? currentSpeechBubble;
  late WidgetRef ref;
  static late MainGame instance;

  @override
  Future<void> onLoad() async {
    add(overworldNavigator);
    world = MainMenu(size);
    instance = this;
  }

  @override
  void onTap() {
    // final state = ref.read(uiProvider);
    ref.read(uiProvider.notifier).set(UIViewDisplayType.game);
    // if(state == UIViewDisplayType.game) {
    //   final dialog = DialogData();
    //   dialog.title = 'Kris says';
    //   dialog.message = 'Hey! Welcome to the first message!';
    //   ref.read(dialogProvider.notifier).set(dialog);
    //   ref.read(uiProvider.notifier).set(UIViewDisplayType.dialog);
    // }
    // if(state == UIViewDisplayType.dialog) {
    //   ref.read(uiProvider.notifier).set(UIViewDisplayType.game);
    // }
    super.onTap();
  }

  void directionPressed(Direction direction) {
    if (overworld != null) {
      overworld!.directionPressed(direction);
    }
  }

  void playerBoughtItem(ShopItem item) {
    // final itemStr = jsonEncode(item.toJson());
    print('player bought ${item.name}');
  }
}
