import 'package:flame/components.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/components/map_runner.dart';
import 'package:karas_quest/components/player_component.dart';

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

    game.mapRunner = world;
    game.world = world!;
    stack.add(world);
  }

  void popWorld() {
    stack.removeLast();
    final world = stack.last;
    game.mapRunner = world;
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

  Map<String, dynamic> toMap() {
    return {

    };
  }

  void initFromMap(Map<String, dynamic> map) {
    
  }
}