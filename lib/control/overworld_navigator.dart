import 'package:flame/components.dart';
import 'package:flame_game/screens/game.dart';
import 'package:flame_game/screens/overworld.dart';

class OverworldNavigator extends Component with HasGameRef<MainGame> {
  final mainWorld = Overworld('map.tmx');
  
  void loadMainWorld() {
    game.overworld = mainWorld;
    game.world = mainWorld;
    // mainWorld.playerEntered();
  }

  void loadWorld(String mapfile) async {
    final newWorld = await Overworld(mapfile);
    game.overworld = newWorld;
    game.world = newWorld;
  }
}