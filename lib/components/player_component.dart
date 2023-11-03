import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' as math;

class PlayerComponent extends SpriteComponent
    with HasGameRef, CollisionCallbacks {
  PlayerComponent()
      : super(
            size: Vector2(32, 32),
            position: Vector2(100, 100),
            anchor: Anchor.center);

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

  void onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {}
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {}
    if (keysPressed.contains(LogicalKeyboardKey.keyW)) {}
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) {}
  }
}
