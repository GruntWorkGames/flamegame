import 'package:flame/components.dart';
import 'package:karas_quest/components/base_map.dart';
import 'package:karas_quest/components/enemy.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/components/npc.dart';
import 'package:karas_quest/control/json/portal.dart';
import 'package:karas_quest/control/json/tile.dart';

class DungeonMap extends Component with HasGameRef<MainGame>, BaseMap {
  @override
  List<Enemy> get enemies => throw UnimplementedError();

  @override
  int get height => throw UnimplementedError();

  @override
  List<NPC> get npcs => throw UnimplementedError();

  @override
  List<Portal> get portals => throw UnimplementedError();

  @override
  List<List<Tile>> get tiles => throw UnimplementedError();

  @override
  int get width => throw UnimplementedError(); 
}