import 'dart:math' as math;

class Tile {

  int x = 0;
  int y = 0;
  
  Tile(this.x, this.y);

  Tile.empty();

  Tile.fromMap(Map<String, dynamic> map) {
    x = map['x'] as int? ?? 0;
    y = map['y'] as int? ?? 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'x' : x,
      'y' : y
    };
  }

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
  // ignore: avoid_equals_and_hash_code_on_mutable_classes, hash_and_equals
  bool operator ==(Object other) {
    if(other is Tile) {
      return x == other.x && y == other.y;
    }
    return false;
  }
}