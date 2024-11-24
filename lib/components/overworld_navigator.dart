import 'package:flame/components.dart';
import 'package:flame_game/components/game.dart';
import 'package:flame_game/components/map_runner.dart';
import 'package:flame_game/components/melee_character.dart';

class OverworldNavigator extends Component with HasGameRef<MainGame> {
  final Map<String, MapRunner> worlds = {};
  List<MapRunner> stack = [];

  void _loadMainWorld() {
    pushWorld('bigmap.tmx');
  }

  Future<void> pushWorld(String mapfile) async {
    late MapRunner? world;

    if(worlds.containsKey(mapfile)) {
      world = worlds[mapfile];
    } else {
      world = MapRunner(mapfile);
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
    game.player = PlayerComponent();
    game.player.data.addDefaultItems();
    stack.clear();
    worlds.clear();
    _loadMainWorld();    
  }

  void pushDungeon(Vector2 location) {
    
  }

  void popDungeon() {
    
  }
}