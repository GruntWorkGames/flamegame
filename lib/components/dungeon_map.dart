import 'package:flame/components.dart';
import 'package:karas_quest/components/base_map.dart';
import 'package:karas_quest/components/enemy.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/components/npc.dart';
import 'package:karas_quest/control/json/portal.dart';

class DungeonMap extends BaseMap with HasGameRef<MainGame> {
  @override
  List<Enemy> get enemies => throw UnimplementedError();

  @override
  List<NPC> get npcs => throw UnimplementedError();

  @override
  List<Portal> get portals => throw UnimplementedError();

  @override
  double get pixelsHigh => throw UnimplementedError();
  
  @override
  double get pixelsWide => throw UnimplementedError();
  
  @override
  void playerEntered() {
  }
  
  @override
  Vector2 get spawnPoint => throw UnimplementedError(); 
}