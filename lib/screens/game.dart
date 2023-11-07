import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_game/components/player_component.dart';
import 'package:flame_game/components/ui.dart';
import 'package:flame_game/control/overworld_navigator.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/main_menu.dart';
import 'package:flame_game/screens/overworld.dart';

class MainGame extends FlameGame {
  PlayerComponent player = PlayerComponent();
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
    if(overworld != null && overworld!.canMoveDirection(direction)) {
      player.move(direction);
    }
  }
}