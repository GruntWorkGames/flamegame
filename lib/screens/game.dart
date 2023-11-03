import 'package:flame/game.dart';
import 'package:flame_game/screens/main_menu.dart';

class MainGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    world = MainMenu(size);
  }
}
