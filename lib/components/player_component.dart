import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_game/components/ui.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/game.dart';

enum PlayerState { beginIdle, idleDown, idleUp, idleLeft, idleRight, walkingLeft, walkingRight, walkingUp, walkingDown, attacking, takingDamage }

class PlayerComponent extends SpriteAnimationComponent with HasGameRef<MainGame> {
  PlayerComponent() : super(size: Vector2(TILESIZE, TILESIZE));
  bool isMoving = false;
  final Map<PlayerState, SpriteAnimation> _animations = {};
  PlayerState _playerState = PlayerState.idleDown;

  @override
  Future<void> onLoad() async {
    // this.sprite = await gameRef.loadSprite('player.png');
    // final playerSpriteSize = Vector2(16, 16);
    // final playerSpriteLoc = Vector2(0,0);
    // final idleFrames = [Vector2(0, 0)];
    anchor = Anchor.topLeft;

    Image? image = await game.images.load('animations/AxemanRed-walk-down.png');
    Map<String, dynamic> jsonData = await game.assets.readJson('images/animations/AxemanRed-walk-down.json');
    _animations[PlayerState.walkingDown] = SpriteAnimation.fromAsepriteData(image, jsonData);

    image = await game.images.load('animations/AxemanRed-walk-up.png');
    jsonData = await game.assets.readJson('images/animations/AxemanRed-walk-up.json');
    _animations[PlayerState.walkingUp] = SpriteAnimation.fromAsepriteData(image, jsonData);

    image = await game.images.load('animations/AxemanRed-walk-left.png');
    jsonData = await game.assets.readJson('images/animations/AxemanRed-walk-left.json');
    _animations[PlayerState.walkingLeft] = SpriteAnimation.fromAsepriteData(image, jsonData);

    image = await game.images.load('animations/AxemanRed-walk-right.png');
    jsonData = await game.assets.readJson('images/animations/AxemanRed-walk-right.json');
    _animations[PlayerState.walkingRight] = SpriteAnimation.fromAsepriteData(image, jsonData);


    image = await game.images.load('animations/AxemanRed-idle-up.png');
    jsonData = await game.assets.readJson('images/animations/AxemanRed-idle-up.json');
    _animations[PlayerState.idleUp] = SpriteAnimation.fromAsepriteData(image, jsonData);

    image = await game.images.load('animations/AxemanRed-idle-down.png');
    jsonData = await game.assets.readJson('images/animations/AxemanRed-idle-down.json');
    _animations[PlayerState.idleDown] = SpriteAnimation.fromAsepriteData(image, jsonData);

    image = await game.images.load('animations/AxemanRed-idle-left.png');
    jsonData = await game.assets.readJson('images/animations/AxemanRed-idle-left.json');
    _animations[PlayerState.idleLeft] = SpriteAnimation.fromAsepriteData(image, jsonData);

    image = await game.images.load('animations/AxemanRed-idle-right.png');
    jsonData = await game.assets.readJson('images/animations/AxemanRed-idle-right.json');
    _animations[PlayerState.idleRight] = SpriteAnimation.fromAsepriteData(image, jsonData);

    _playerState = PlayerState.idleDown;
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
        _stateChanged(PlayerState.walkingUp);
        break;
      case Direction.down:
        distance.y += TILESIZE;
        _stateChanged(PlayerState.walkingDown);
        break;
      case Direction.left:
        distance.x -= TILESIZE;
        _stateChanged(PlayerState.walkingLeft);
        break;
      case Direction.right:
        distance.x += TILESIZE;
        _stateChanged(PlayerState.walkingRight);
        break;
    }

    final lastPos = position.clone();

    final move = MoveEffect.by(distance, EffectController(
      duration: .24
    ), onComplete: () {
      // snap to grid. issue with moveTo/moveBy not being perfect...
      position = lastPos + distance;
      final tilePos = posToTile(position);
      game.overworld?.steppedOnTile(tilePos);
      isMoving = false;
      final tile = posToTile(position);
      UI.debugLabel.text = '${tile.x}, ${tile.y}';
      _stateChanged(PlayerState.beginIdle);
    },);
    move.removeOnFinish = true;

    add(move);
  }

  void _stateChanged(PlayerState st) {
    if(st == PlayerState.beginIdle) {
      switch(_playerState) {
        case PlayerState.walkingUp:
          animation = _animations[PlayerState.idleUp];
          return;
        case PlayerState.walkingDown:
          animation = _animations[PlayerState.idleDown];
          return;
        case PlayerState.walkingLeft:
          animation = _animations[PlayerState.idleLeft];
          return;
        case PlayerState.walkingRight:
          animation = _animations[PlayerState.idleRight];   
          return;
        case PlayerState.beginIdle:
        case PlayerState.idleDown:
        case PlayerState.idleUp:
        case PlayerState.idleLeft:
        case PlayerState.idleRight:
        case PlayerState.attacking:
        case PlayerState.takingDamage:
      }
    } else {
      animation = _animations[st];
      _playerState = st;
    }   
  }
}
