import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/components/ui.dart';
import 'package:flame_game/control/overworld_navigator.dart';
import 'package:flame_game/control/provider/dialog_provider.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/main_menu.dart';
import 'package:flame_game/screens/overworld.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainGame extends FlameGame with HorizontalDragDetector, VerticalDragDetector, TapDetector {
  MeleeCharacter player = MeleeCharacter();
  Overworld? overworld;
  final overworldNavigator = OverworldNavigator();
  final ui = UI.instance;
  Component? currentSpeechBubble;
  late WidgetRef ref;
  
  @override
  Future<void> onLoad() async {
    add(overworldNavigator);
    world = MainMenu(size);
  }

  @override
  void onTap() {
    final state = ref.read(uiProvider);
    if(state == UIScreenType.game) {
      final dialog = DialogData();
      dialog.title = 'TITLE';
      dialog.message = 'Hey! Welcome to the first message!';
      ref.read(dialogProvider.notifier).set(dialog);
      ref.read(uiProvider.notifier).set(UIScreenType.dialog);
    }
    if(state == UIScreenType.dialog) {
      ref.read(uiProvider.notifier).set(UIScreenType.game);
    }
    super.onTap();
  }

  void directionPressed(Direction direction) {
    if (overworld != null) {
      overworld!.directionPressed(direction);
    }
  }

  @override
  void onVerticalDragEnd(DragEndInfo info) {
    super.onVerticalDragEnd(info);
    final v = info.velocity;
    if(v.y > 0) {
      directionPressed(Direction.down);
    }
    if(v.y < 0) {
      directionPressed(Direction.up);
    }
  }

  @override
  void onHorizontalDragEnd(DragEndInfo info) {
    super.onHorizontalDragEnd(info);
    final v = info.velocity;
    if(v.x > 0) {
      directionPressed(Direction.right);
    }
    if(v.x < 0) {
      directionPressed(Direction.left);
    }
  }
}
