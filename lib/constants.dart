import 'package:flame_game/direction.dart';
import 'package:vector_math/vector_math_64.dart';

const double TILESIZE = 32;

  Vector2 posToTile(Vector2 pos) {
    return Vector2(pos.x / TILESIZE, pos.y / TILESIZE);
  }

  Vector2 tileToPos(Vector2 tile) {
    return Vector2(tile.x * TILESIZE, tile.y * TILESIZE);
  }

  Vector2 getNextTile(Direction direction, Vector2 pos) {
    switch(direction) {
      case Direction.up:
        return Vector2(pos.x, pos.y - 1);
      case Direction.down:
        return Vector2(pos.x, pos.y + 1);
      case Direction.left:
        return Vector2(pos.x - 1, pos.y);
      case Direction.right:
        return Vector2(pos.x + 1, pos.y);
    }
  }