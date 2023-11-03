import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_game/constants.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' as math;

class PlayerComponent extends SpriteComponent with HasGameRef, CollisionCallbacks, KeyboardHandler {
  PlayerComponent() : super(size: Vector2(TILESIZE, TILESIZE), position: Vector2(TILESIZE, TILESIZE));

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    this.sprite = await gameRef.loadSprite('player.png');
  }

  void takeHit() {}

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      position.x += TILESIZE;
    } else if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      position.x -= TILESIZE;
    }else if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      position.y += TILESIZE;
    } else if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      position.y -= TILESIZE;
    }

    return super.onKeyEvent(event, keysPressed);
  }
}
