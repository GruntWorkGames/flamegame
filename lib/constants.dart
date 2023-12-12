import 'package:flame/components.dart';
import 'package:flame_game/direction.dart';
import 'package:flutter/material.dart';

const double TILESIZE = 16;
final mainColor = Colors.grey[600]!;
final borderColor = Colors.grey[700]!;
// final mainColor = Colors.grey[400]!;
// final borderColor = Colors.blue;
final selectedColor = Color.fromARGB(255, 49, 49, 49);
final borderRadius = 5.0;
final borderWidth = 2.0;
final buttonId = 400;

Vector2 posToTile(Vector2 pos) {
  return Vector2(pos.x / TILESIZE, pos.y / TILESIZE);
}

Vector2 tileToPos(Vector2 tile) {
  return Vector2(tile.x * TILESIZE, tile.y * TILESIZE);
}

Vector2 getNextTile(Direction direction, Vector2 pos) {
  switch (direction) {
    case Direction.up:
      return Vector2(pos.x, pos.y - 1);
    case Direction.down:
      return Vector2(pos.x, pos.y + 1);
    case Direction.left:
      return Vector2(pos.x - 1, pos.y);
    case Direction.right:
      return Vector2(pos.x + 1, pos.y);
    case Direction.none:
      return pos;
  }
}

Direction directionFromPosToPos(Vector2 posA, Vector2 posB) {
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