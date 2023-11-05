import 'package:flame/components.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/game.dart';

class PlayerComponent extends SpriteComponent with HasGameRef<MainGame> {
  PlayerComponent() : super(size: Vector2(TILESIZE, TILESIZE));

  @override
  Future<void> onLoad() async {
    this.sprite = await gameRef.loadSprite('player.png');
    anchor = Anchor.topLeft;
  }

  void move(Direction direction) {
    switch (direction) {
      case Direction.up:
        position.y -= TILESIZE;
        break;
      case Direction.down:
        position.y += TILESIZE;
        break;
      case Direction.left:
        position.x -= TILESIZE;
        break;
      case Direction.right:
        position.x += TILESIZE;
        break;
    }
    final tilePos = posToTile(position);
    game.overworld?.steppedOnTile(tilePos);
  }
}
