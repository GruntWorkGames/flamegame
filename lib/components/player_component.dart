import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_game/components/ui.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/game.dart';

class PlayerComponent extends SpriteComponent with HasGameRef<MainGame> {
  PlayerComponent() : super(size: Vector2(TILESIZE, TILESIZE));
  bool isMoving = false;

  @override
  Future<void> onLoad() async {
    this.sprite = await gameRef.loadSprite('player.png');
    anchor = Anchor.topLeft;
  }

  void move(Direction direction) {
    if(isMoving) {
      return;
    }
    isMoving = true;
    final distance = Vector2(0, 0);
    switch (direction) {
      case Direction.up:
        distance.y -= TILESIZE;
        break;
      case Direction.down:
        distance.y += TILESIZE;
        break;
      case Direction.left:
        distance.x -= TILESIZE;
        break;
      case Direction.right:
        distance.x += TILESIZE;
        break;
    }

    final lastPos = position.clone();

    final move = MoveEffect.by(distance, EffectController(
      duration: .1
    ),onComplete: () {
      // snap to grid. issue with moveTo/moveBy not being perfect...
      position = lastPos + distance;
      final tilePos = posToTile(position);
      game.overworld?.steppedOnTile(tilePos);
      isMoving = false;
      final tile = posToTile(position);
      UI.debugLabel.text = '${tile.x}, ${tile.y}';
    },);
    move.removeOnFinish = true;

    add(move);
  }
}
