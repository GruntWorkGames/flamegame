import 'package:flame/components.dart';
import 'package:karas_quest/control/json/map_data.dart';

class Portal {

  final Vector2 position;
  MapData mapData;

  Portal(this.mapData, this.position);
}