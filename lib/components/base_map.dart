import 'package:karas_quest/components/enemy.dart';
import 'package:karas_quest/components/npc.dart';
import 'package:karas_quest/control/json/portal.dart';
import 'package:karas_quest/control/json/tile.dart';

mixin BaseMap {
  int get width;
  int get height;
  List<List<Tile>> get tiles;
  List<Portal> get portals;
  List<NPC> get npcs;
  List<Enemy> get enemies;
}