import 'dart:math';

class FloorData {
  int width = 0;
  int height = 0;
  int numOpenTiles = 0;
  List<List<bool>> bools;
  FloorData(this.bools, this.width, this.height);
}

class FloorFactory {
  /// generate a grid of bools. True means blocked, false means floor.
  static FloorData generate(int w, int h, int tilesize, int numOpenTiles) {
    // init grid
    // final grid = getRectGrid(w, h, tilesize);
    final bools = getBooleanGrid(w, h);

    // set controller in the center
    var cx = w ~/ 2;
    var cy = h ~/ 2;

    // give controller random direction
    // cdir == direction
    var cdir = Random().nextInt(4);

    // odds for changing direction
    const odds = 2;

    // create using x steps
    var numTiles = 0;
    while (numTiles < numOpenTiles) {
      // place a floor tile at controller pos
      // if we havent already been in this tile, count it as placing a new one.
      if (!bools[cx][cy]) {
        numTiles++;
      }

      bools[cx][cy] = false;

      // randomize direction
      if (Random().nextInt(odds) == odds - 1) {
        cdir = Random().nextInt(4);
      }

      // move the controller
      final xdir = _lengthdirX(1, cdir * 90).toInt();
      final ydir = _lengthdirY(1, cdir * 90).toInt();
      cx += xdir;
      cy += ydir;

      // dont move outside of the grid
      cx = clamp(cx, 1, w - 2);
      cy = clamp(cy, 1, h - 2);
    }

    return FloorData(bools, w, h);
  }

  static List<List<bool>> getBooleanGrid(int w, int h) {
    final grid = <List<bool>>[];

    for (var x = 0; x < w; x++) {
      final row = <bool>[];
      grid.add(row);

      for (var y = 0; y < h; y++) {
        row.add(true);
      }
    }

    return grid;
  }

  static double _lengthdirX(double length, double angle) {
    return length * cos(angle * (pi / 180));
  }

  static double _lengthdirY(double length, double angle) {
    return length * sin(angle * (pi / 180));
  }

  static int clamp(int value, int min, int max) {
    return value.clamp(min, max);
  }
}