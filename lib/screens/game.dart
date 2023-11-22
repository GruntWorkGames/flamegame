import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/components/ui.dart';
import 'package:flame_game/control/overworld_navigator.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/main_menu.dart';
import 'package:flame_game/screens/overworld.dart';

class MainGame extends FlameGame {
  MeleeCharacter player = MeleeCharacter();
  Overworld? overworld;
  final overworldNavigator = OverworldNavigator();
  final ui = UI();
  Component? currentSpeechBubble;

  @override
  Future<void> onLoad() async {
    add(overworldNavigator);
    world = MainMenu(size);
  }

  void directionPressed(Direction direction) {
    if (overworld != null) {
      overworld!.directionPressed(direction);
    }
  }
}
