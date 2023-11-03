import 'package:flame/components.dart';
import 'package:flame_game/constants.dart';
import 'package:flutter/services.dart';

class PlayerComponent extends SpriteComponent with HasGameRef, KeyboardHandler {
  PlayerComponent() : super(size: Vector2(TILESIZE, TILESIZE), position: Vector2(TILESIZE, TILESIZE));

  @override
  Future<void> onLoad() async {
    this.sprite = await gameRef.loadSprite('player.png');
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
