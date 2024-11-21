import 'dart:math' as math;

class Tile {

  int x = 0;
  int y = 0;

  Tile.empty();
  
  Tile(this.x, this.y);

  Tile.fromPoint(math.Point<int> point) {
    x = point.x;
    y = point.y;
  }

  math.Point<int> toPoint() {
    return math.Point<int>(x,y);
  }

  double distanceTo(Tile tile) {
    final p1 = toPoint();
    final p2 = tile.toPoint();
    return p1.distanceTo(p2);
  }

  @override
  bool operator ==(Object other) {
    if(other is Tile) {
      return x == other.x && y == other.y;
    }
    return false;
  }
}