import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/game.dart';

class DirectionalPad extends PositionComponent with HasGameRef<MainGame> {
  @override
  FutureOr<void> onLoad() async {
        final leftArrow = await game.loadSprite('arrow_left.png');
    final rightArrow = await game.loadSprite('arrow_right.png');
    final upArrow = await game.loadSprite('arrow_up.png');
    final downArrow = await game.loadSprite('arrow_down.png');
    const size = 64.0;
    final bottom = game.size.y - size;

    final left = SpriteButtonComponent(
        button: leftArrow,
        size: Vector2(size, size),
        position: Vector2(0, bottom - size),
        onPressed: () {
          game.player?.move(Direction.left);
        });

    final right = SpriteButtonComponent(
        button: rightArrow,
        size: Vector2(size, size),
        position: Vector2(size * 2, bottom - size),
        onPressed: () {
          game.player?.move(Direction.right);
        });

    final up = SpriteButtonComponent(
        button: upArrow,
        size: Vector2(size, size),
        position: Vector2(size, bottom - size * 2),
        onPressed: () {
          game.player?.move(Direction.up);
        });

    final down = SpriteButtonComponent(
        button: downArrow,
        size: Vector2(size, size),
        position: Vector2(size, bottom),
        onPressed: () {
          game.player?.move(Direction.down);
        });

    add(left);
    add(right);
    add(up);
    add(down);
  }
}