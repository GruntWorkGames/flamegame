import 'package:flame/components.dart';
import 'package:flame_game/control/enum/direction.dart';
import 'package:flutter/material.dart';
import 'package:flame_game/control/objects/tile.dart' as k;

const int TILESIZE = 16;
final mainColor = Colors.grey[600]!;
final borderColor = Colors.grey[700]!;
// final mainColor = Colors.grey[400]!;
// final borderColor = Colors.blue;
final selectedColor = Color.fromARGB(255, 49, 49, 49);
final borderRadius = 5.0;
final borderWidth = 2.0;
final buttonId = 400;

k.Tile posToTile(Vector2 pos) {
  final x = (pos.x / TILESIZE).toInt();
  final y = (pos.y / TILESIZE).toInt();
  return k.Tile(x, y);
}

Vector2 tileToPos(k.Tile tile) {
  return Vector2(tile.x.toDouble() * TILESIZE, tile.y.toDouble() * TILESIZE);
}

k.Tile getNextTile(Direction direction, k.Tile pos) {
  switch (direction) {
    case Direction.up:
      return k.Tile(pos.x, pos.y - 1);
    case Direction.down:
      return k.Tile(pos.x, pos.y + 1);
    case Direction.left:
      return k.Tile(pos.x - 1, pos.y);
    case Direction.right:
      return k.Tile(pos.x + 1, pos.y);
    case Direction.none:
      return pos;
  }
}

k.Tile toTile(Vector2 vec) {
  return k.Tile(vec.x.toInt(), vec.y.toInt());
}

Vector2 toVec2(k.Tile point) {
  return Vector2(point.x.toDouble(), point.y.toDouble());
}

Direction directionFromPosToPos(k.Tile posA, k.Tile posB) {
  if (posA == posB) {
    return Direction.none;
  }

  if (posA.x == posB.x) {
    // moved up/down
    return posB.y > posA.y ? Direction.down : Direction.up;
  } else if (posA.y == posB.y) {
    return posB.x > posA.x ? Direction.right : Direction.left;
  } else {
    return Direction.none;
  }
}

final phoneTextTheme = TextTheme();

final mainTheme = ThemeData(
  textTheme: TextTheme(),
  textButtonTheme: TextButtonThemeData(), 
  iconButtonTheme: IconButtonThemeData(),
  iconTheme: IconThemeData(),
  actionIconTheme: ActionIconThemeData(),
  inputDecorationTheme: InputDecorationTheme()
);

final boxDecoration = BoxDecoration(
  border: Border.all(color: borderColor, width: borderWidth),
  borderRadius: BorderRadius.circular(borderRadius),
  color: mainColor);

  final titleStyle = TextStyle(fontSize: 18, color: Colors.white);