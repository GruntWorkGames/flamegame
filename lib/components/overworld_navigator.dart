import 'package:flame/components.dart';
import 'package:flame_game/components/game.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/components/overworld.dart';

class OverworldNavigator extends Component with HasGameRef<MainGame> {
  final Map<String, Overworld> worlds = {};
  Overworld? lastWorld;
  List<Overworld> stack = [];

  void loadMainWorld() {
    pushWorld('bigmap.tmx');
  }

  Future<void> pushWorld(String mapfile) async {
    late Overworld? world;

    if(worlds.containsKey(mapfile)) {
      world = worlds[mapfile];
    } else {
      world = await Overworld(mapfile);
      worlds[mapfile] = world;
    }

    game.overworld = world;
    game.world = world!;
    stack.add(world);
  }

  void popWorld() {
    stack.removeLast();
    final world = stack.last;
    game.overworld = world;
    game.world = world;
  }

  void loadNewGame() {
    worlds.clear();
    game.player = PlayerComponent();
    game.player.data.addDefaultItems();
    stack.clear();
    worlds.clear();
    loadMainWorld();    
  }
}