import 'dart:io';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/components/map_runner.dart';
import 'package:karas_quest/control/json/map_data.dart';
import 'package:karas_quest/control/json/save_file.dart';

class MapLoader extends Component with HasGameRef<MainGame> {
  final Map<String, MapRunner> worlds = {};
  List<MapRunner> stack = [];
  final viewport = FixedResolutionViewport(resolution: Vector2(480*2, 320*2));

  Future<void> pushWorld(String mapfile) async {
    late MapRunner? world;

    if(worlds.containsKey(mapfile)) {
      world = worlds[mapfile];
    } else {
      world = MapRunner.fromMapFile(mapfile);
    }

    worlds[mapfile] = world!;
    game.mapRunner = world;
    game.world = world;
    stack.add(world);
  }

  // load the maps, but does not call onLoad until they are assigned
  void _loadMapRunner(MapData map) {
    final runner = MapRunner.fromMapData(map);
    worlds[runner.mapfile] = runner;
    stack.add(runner);
  }

  // assign the last map in the stack
  void _startGame() {
    final runner = stack.last;
    game.mapRunner = runner;
    game.world = runner;
    if(Platform.isMacOS || Platform.isWindows) {
      final cameraComponent = CameraComponent(
        world: runner,
        viewport: viewport
      );
      game.camera = cameraComponent;
    }
    add(runner);
  }

  void popWorld() {
    stack.removeLast();
    final world = stack.last;
    game.mapRunner = world;
    game.world = world;
  }

  void save(SaveFile savefile) {
    savefile.mapStack = stack.map((map) {
      return map.toMapData();
    }).toList();
  }

  void initFromSaveFile(SaveFile saveFile) {
    final maps = saveFile.mapStack;
    for(final map in maps) {
      _loadMapRunner(map);
    }

    // start on last map
    _startGame();
  }
}