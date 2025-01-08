import 'package:flame/components.dart';
import 'package:karas_quest/control/enum/map_type.dart';

class Portal {
  final Vector2 position;
  final String map;
  MapType mapType = MapType.crafted;
  Portal(this.map, this.position, this.mapType);
}