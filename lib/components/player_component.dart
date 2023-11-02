import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_game/components/bullet_component.dart';
import 'package:flame_game/components/enemy_component.dart';
import 'package:flame_game/components/explosion_component.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' as math;

class PlayerComponent extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  late TimerComponent bulletCreator;
  final velocity = Vector2(0, 0);
  final mousePosition = Vector2(0, 0);
  final gun = PositionComponent(position: Vector2(0, -10));

  PlayerComponent()
      : super(
          size: Vector2(50, 75),
          position: Vector2(100, 500),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    gun.add(
      bulletCreator = TimerComponent(
        period: 0.05,
        repeat: true,
        autoStart: false,
        onTick: _createBullet,
      ),
    );
    add(gun);
    animation = await gameRef.loadSpriteAnimation(
      'rogue_shooter/player.png',
      SpriteAnimationData.sequenced(
        stepTime: 0.2,
        amount: 4,
        textureSize: Vector2(32, 39),
      ),
    );
  }

  void _createBullet() {
    const offset = 1.5708;
    final direction = position - mousePosition;
    final radians = atan2(direction.y, direction.x) - offset;
    const barrelDist = -50.0;
    final x = barrelDist * cos(radians + offset);
    final y = barrelDist * sin(radians + offset);
    final bulletAngles = <double>[];

    for (var i = 0; i < 4; i++) {
      var angle = Random().nextDouble() * 50;
      final sign = Random().nextBool();
      if (!sign) {
        angle *= -1;
      }

      bulletAngles.add(math.radians(angle));
    }

    gameRef.addAll(
      bulletAngles.map(
        (angle) {
          final bullet = BulletComponent(
            position: position + Vector2(x - 4, y),
            angle: radians + angle,
          );
          bullet.priority = -1;
          return bullet;
        },
      ),
    );
  }

  void beginFire() {
    bulletCreator.timer.start();
  }

  void stopFire() {
    bulletCreator.timer.pause();
  }

  void takeHit() {
    gameRef.add(ExplosionComponent(position: position));
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is EnemyComponent) {
      other.takeHit();
    }
  }

  void onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    velocity.x = 0;
    velocity.y = 0;
    const speed = 500.0;
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      velocity.x -= speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      velocity.x += speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      velocity.y -= speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      velocity.y += speed;
    }
  }

  void updatePlayer(double dt) {
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;

    lookAtMouse();
  }

  void lookAtMouse() {
    final direction = position - mousePosition;
    final radians = atan2(direction.y, direction.x);
    const offset = 1.5708;
    //angle = radians - 1.5708; // -90 degrees
    transform.angle = radians - offset;
  }

  // void onMouseMove(PointerHoverInfo info) {
  //   final pos = info.eventPosition.game;
  //   mousePosition.setFrom(pos);
  // }

  // void onPanStart(DragStartInfo info) {
  //   final pos = info.eventPosition.game;
  //   mousePosition.setFrom(pos);
  // }

  // void onPanUpdate(DragUpdateInfo info) {
  //   final pos = info.eventPosition.game;
  //   mousePosition.setFrom(pos);
  // }
}
