import 'package:flame/components.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/screens/components/game.dart';
import 'package:flame_game/screens/components/overworld.dart';

class OverworldNavigator extends Component with HasGameRef<MainGame> {
  final Map<String, Overworld> worlds = {};
  Overworld? lastWorld;

  void loadMainWorld() {
    loadWorld('map.tmx');
  }

  Future<void> loadWorld(String mapfile) async {
    lastWorld = game.overworld;
    if(worlds.containsKey(mapfile)) {
      game.overworld = worlds[mapfile];
      game.world = worlds[mapfile]!;
    } else { // create new
      final newWorld = await Overworld(mapfile);
      game.overworld = newWorld;
      game.world = newWorld;
      worlds[mapfile] = newWorld;
    }
  }

  void setWorld(Overworld world){
    game.overworld = world;
    game.world = world;
  }

  void loadNewGame() {
    worlds.clear();
    game.player = PlayerComponent();
    loadMainWorld();    
  }
}