import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/json/inventory.dart';
import 'package:flame_game/control/overworld_navigator.dart';
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

  @override
  Future<void> onLoad() async {
    add(overworldNavigator);
    instance = this;
    overworldNavigator.loadMainWorld();
  }

  @override
  void onTap() {
    final state = ref.read(uiProvider);
    if (state == UIViewDisplayType.dialog || state == UIViewDisplayType.shop) {
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
