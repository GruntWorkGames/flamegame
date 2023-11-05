import 'package:flame/game.dart';
import 'package:flame_game/components/player_component.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/main_menu.dart';
import 'package:flame_game/screens/overworld.dart';

class MainGame extends FlameGame {
  late final PlayerComponent player;
  late final Overworld overworld;

  @override
  Future<void> onLoad() async {
    world = MainMenu(size);
  }

  void directionPressed(Direction direction) {
    if(overworld.canMoveDirection(direction)) {
      player.move(direction);
    }
  }
}
