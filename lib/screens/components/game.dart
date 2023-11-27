import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/json/shop.dart';
import 'package:flame_game/control/overworld_navigator.dart';
import 'package:flame_game/control/provider/dialog_provider.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/components/main_menu.dart';
import 'package:flame_game/screens/components/overworld.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainGame extends FlameGame with TapDetector {
  MeleeCharacter player = MeleeCharacter();
  Overworld? overworld;
  final overworldNavigator = OverworldNavigator();
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
    ref.read(uiProvider.notifier).set(UIViewDisplayType.game);
    super.onTap();
  }

  void directionPressed(Direction direction) {
    if (overworld != null) {
      overworld!.directionPressed(direction);
    }
  }

  void playerBoughtItem(ShopItem item) {
    if(player.money < item.cost) {
      final dialog = DialogData();
      dialog.title = 'Oops!';
      dialog.message = 'Sorry, you don\'t have enough gold!';
      ref.read(dialogProvider.notifier).set(dialog);
      ref.read(uiProvider.notifier).set(UIViewDisplayType.dialog);
    } else {
      player.money -= item.cost;
      ref.read(uiProvider.notifier).set(UIViewDisplayType.game);
    }
  }
}
