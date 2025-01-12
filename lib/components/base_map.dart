import 'package:flame/components.dart';
import 'package:karas_quest/components/enemy.dart';
import 'package:karas_quest/components/enemy_creator.dart';
import 'package:karas_quest/components/npc.dart';
import 'package:karas_quest/components/world_map.dart';
import 'package:karas_quest/control/json/map_data.dart';
import 'package:karas_quest/control/json/portal.dart';
import 'package:karas_quest/control/json/tile.dart';

abstract class BaseMap extends Component {
  PortalDelegate? portalDelegate;
  double get pixelsWide;
  double get pixelsHigh;
  List<List<bool>> tiles = List<List<bool>>.empty(growable: false);  
  List<List<Function?>> triggerTiles = List<List<Function?>>.empty(growable: false);
  List<List<NPC?>> npcTiles = List<List<NPC?>>.empty(growable: false);
  List<Portal> get portals;
  List<NPC> get npcs;
  Vector2 get spawnPoint;
  EnemyCreator? enemyCreator;

  void generateTiles(int width, int height) {
    tiles = List<List<bool>>.generate(
        width,
        (index) => List<bool>.generate(height, (index) => false,
            growable: false),
        growable: false);

    triggerTiles = List<List<Function?>>.generate(
        width,
        (index) =>
            List<Function?>.generate(height, (index) => null), growable: false);

    npcTiles = List<List<NPC?>>.generate(
        width,
        (index) =>
            List<NPC?>.generate(height, (index) => null, growable: false),
        growable: false);
  }

  void playerEntered();
}