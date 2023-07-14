import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rogue_shooter/components/enemy_creator.dart';
import 'package:rogue_shooter/components/player_component.dart';
import 'package:rogue_shooter/components/star_background_creator.dart';

class RogueShooterGame extends FlameGame
    with
        PanDetector,
        HasCollisionDetection,
        KeyboardEvents,
        MouseMovementDetector {
  static const String description = '''
    A simple space shooter game used for testing performance of the collision
    detection system in Flame.
  ''';

  late final PlayerComponent player;
  late final TextComponent componentCounter;
  late final TextComponent scoreText;

  static late final TextComponent debugLabel;

  int score = 0;

  @override
  Future<void> onLoad() async {
    add(
      debugLabel = TextComponent(
        position: size - Vector2(0, 70),
        anchor: Anchor.bottomRight,
        priority: 1,
      ),
    );

    add(player = PlayerComponent());

    addAll([
      FpsTextComponent(
        position: size - Vector2(0, 50),
        anchor: Anchor.bottomRight,
      ),
      scoreText = TextComponent(
        position: size - Vector2(0, 25),
        anchor: Anchor.bottomRight,
        priority: 1,
      ),
      componentCounter = TextComponent(
        position: size,
        anchor: Anchor.bottomRight,
        priority: 1,
      ),
    ]);

    add(EnemyCreator());
    add(StarBackGroundCreator());
  }

  @override
  void update(double dt) {
    super.update(dt);
    scoreText.text = 'Score: $score';
    componentCounter.text = 'Components: ${children.length}';
    player.updatePlayer(dt);
  }

  @override
  void onPanStart(DragStartInfo info) {
    player.beginFire();
    player.onPanStart(info);
  }

  @override
  void onPanEnd(_) {
    player.stopFire();
  }

  @override
  void onPanCancel() {
    player.stopFire();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.onPanUpdate(info);
  }

  void increaseScore() {
    score++;
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    player.onKeyEvent(event, keysPressed);
    return KeyEventResult.handled;
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    player.onMouseMove(info);
  }
}
