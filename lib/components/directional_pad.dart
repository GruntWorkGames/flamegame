import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/components/game.dart';

class DirectionalPad extends PositionComponent with HasGameRef<MainGame> {
  @override
  FutureOr<void> onLoad() async {
    final leftArrow = await game.loadSprite('arrow_left.png');
    final leftArrowPress = await game.loadSprite('arrow_left_pressed.png');

    final rightArrow = await game.loadSprite('arrow_right.png');
    final rightArrowPress = await game.loadSprite('arrow_right_pressed.png');

    final upArrow = await game.loadSprite('arrow_up.png');
    final upArrowPress = await game.loadSprite('arrow_up_pressed.png');

    final downArrow = await game.loadSprite('arrow_down.png');
    final downArrowPress = await game.loadSprite('arrow_down_pressed.png');

    const size = 64.0;
    final bottom = size;

    final left = SpriteButtonComponent(
        button: leftArrow,
        buttonDown: leftArrowPress,
        size: Vector2(size, size),
        position: Vector2(0, bottom - size),
        onPressed: () {
          game.directionPressed(Direction.left);
        });

    final right = SpriteButtonComponent(
        button: rightArrow,
        buttonDown: rightArrowPress,
        size: Vector2(size, size),
        position: Vector2(size * 2, bottom - size),
        onPressed: () {
          game.directionPressed(Direction.right);
        });

    final up = SpriteButtonComponent(
        button: upArrow,
        buttonDown: upArrowPress,
        size: Vector2(size, size),
        position: Vector2(size, bottom - size * 2),
        onPressed: () {
          game.directionPressed(Direction.up);
        });

    final down = SpriteButtonComponent(
        button: downArrow,
        buttonDown: downArrowPress,
        size: Vector2(size, size),
        position: Vector2(size, bottom),
        onPressed: () {
          game.directionPressed(Direction.down);
        });

    add(left);
    add(right);
    add(up);
    add(down);
  }
}