import 'package:flame/components.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/components/map_runner.dart';

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
      world = MapRunner.fromMapFile(mapfile);
      worlds[mapfile] = world;
    }

    game.mapRunner = world;
    game.world = world!;
    stack.add(world);
  }

  void _loadMapRunner(MapRunner runner, String mapFile) {
    worlds[mapFile] = runner;
    game.mapRunner = runner;
    game.world = runner;
    stack.add(runner);
  }

  void popWorld() {
    stack.removeLast();
    final world = stack.last;
    game.mapRunner = world;
    game.world = world;
  }

  void loadNewGame() {
    // game.player = PlayerComponent();
    // game.player.data.addDefaultItems();
    stack.clear();
    worlds.clear();
    _loadMainWorld();    
  }

  Map<String, dynamic> toMap() {
    return {
      'stack' : stack.map((mapRunner) => mapRunner.toMap()).toList()
    };
  }

  Future<void> initFromMap(Map<String, dynamic> map) async {
    final mapStack = map['stack'] as List<dynamic>? ?? [];
    for(final map in mapStack) {
      print(map);
      if(map is Map<String, dynamic>) {
        final mapFile = map['mapFile'] as String? ?? 'bigmap.tmx';
        final mapRunner = MapRunner.fromMapFile(mapFile);
        // mapRunner.data = map;
        _loadMapRunner(mapRunner, mapRunner.mapfile);
      }
    }
  }
}