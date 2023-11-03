import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_game/screens/main_menu.dart';

class MainGame extends FlameGame with HasKeyboardHandlerComponents {
  @override
  Future<void> onLoad() async {
    world = MainMenu(size);
  }
}
