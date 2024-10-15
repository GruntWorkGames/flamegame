import 'dart:math';
import 'package:vector_math/vector_math.dart';

class Room {
  late final List<List<bool>> _floorplan;
  final floorTiles = [];
  final wallTiles = [];
  final floorsize = Vector2(8, 12);

  Room() {
    final numFloorTiles = 40;
    _floorplan = FloorPlanGenerator().generate(floorsize, numFloorTiles);
    _buildFromFloorplan(_floorplan, floorsize);
  }

  bool isTileOpen(Vector2 tile) {
    if (tile.x >= floorsize.x || tile.y >= floorsize.y) {
      return false;
    }
    if (tile.y <= 0 || tile.x <= 0) {
      return false;
    }
    final val = !_floorplan[tile.x.toInt()][tile.y.toInt()];
    return val;
  }

  void _buildFromFloorplan(List<List<bool>> floorplan, Vector2 floorSize) {
    for (int x = 0; x < floorSize.x; x++) {
      for (int y = 0; y < floorSize.y; y++) {
        final isWall = _floorplan[x][y];
        if (isWall) {
          // final blockPos = Vector2(x.toDouble(), y.toDouble());
          final tilePos = Vector2(x.toDouble(), y.toDouble());
          wallTiles.add(tilePos);
          // final block = _create(blockPos);
          // blocks.add(block);
          // wallMesh[tilePos] = block;
        } else {
          // final tile = _createSteppingStone(Vector2(x, y));
          // blocks.add(tile);
          final tilepos = Vector2(x.toDouble(), y.toDouble());
          floorTiles.add(tilepos);
        }
      }
    }
  }
}

class FloorPlanGenerator {
  
  List<List<bool>> generate(Vector2 size, int numOpenTiles) {
    final floorData = _fillFloorArray(size);

    // Set controller in center
    int cx = size.x.toInt() ~/ 2;
    int cy = size.y ~/ 2;

    final random = Random();

    // Random direction
    var cdir = random.nextInt(4); // 0-3 range

    // Odds of changing direction (removed unused variable)

    var numTilesOpened = 0;

    while (numTilesOpened < numOpenTiles) {
      // Place a floor tile at controller position
      if (floorData[cx][cy]) {
        numTilesOpened++;
      }
      floorData[cx][cy] = false;

      // Randomize direction
      if (random.nextBool()) {
        cdir = random.nextInt(4);
      }

      // Move the controller
      final xDir = _lengthDirX(1, cdir * 90);
      final yDir = _lengthDirY(1, cdir * 90);

      // Randomly change either x or y, not both
      if (random.nextBool()) {
        cx += xDir.toInt();
      } else {
        cy += yDir.toInt();
      }

      cx = _clamp(cx, 1, size.x.toInt() - 2);
      cy = _clamp(cy, 1, size.y.toInt() - 2);
    }

    return floorData;
  }

  int _clamp(int value, int min, int max) => value.clamp(min, max);

  // Helper function to convert degrees to radians
  double _radians(double degrees) => degrees * pi / 180;

  List<List<bool>> _fillFloorArray(Vector2 size) {
    final floorData = List.generate(size.x.toInt(), (_) => List.filled(size.y.toInt(), true));
    return floorData;
  }

  double _lengthDirX(double length, double angle) {
    return cos(_radians(angle)) * length;
  }

  double _lengthDirY(double length, double angle) {
    return sin(_radians(angle)) * length;
  }
}


