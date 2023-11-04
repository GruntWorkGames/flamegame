import 'package:flame/components.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/game.dart';

class PlayerComponent extends SpriteComponent with HasGameRef<MainGame> {
  PlayerComponent() : super(
            size: Vector2(TILESIZE, TILESIZE),
            position: Vector2(TILESIZE, TILESIZE));

  @override
  Future<void> onLoad() async {
    this.sprite = await gameRef.loadSprite('player.png');
    game.player = this;
  }

  void move(Direction direction) {
    switch (direction) {
      case Direction.up:
        position.y -= TILESIZE;
      case Direction.down:
        position.y += TILESIZE;
      case Direction.left:
        position.x -= TILESIZE;
        break;
      case Direction.right:
        position.x += TILESIZE;
        break;
    }
  }
}
