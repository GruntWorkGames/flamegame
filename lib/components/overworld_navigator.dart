import 'package:flame/components.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/components/map_runner.dart';
import 'package:karas_quest/control/json/save_file.dart';

class MapLoader extends Component with HasGameRef<MainGame> {
  final Map<String, MapRunner> worlds = {};
  List<MapRunner> stack = [];

  void _loadDefaultMap() {
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

  List<dynamic> toMap() {
    return stack.map((mapRunner) => mapRunner.toMap()).toList();
  }

  void initFromSaveFile(SaveFile saveFile) {
    final maps = saveFile.mapStack;
    for(final map in maps) {
      final mapRunner = MapRunner.fromMapData(map);
      _loadMapRunner(mapRunner, map.mapFile);
    }
  }
}