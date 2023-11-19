import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/image_composition.dart';
import 'package:flame_game/components/player.dart';
import 'package:flame_game/components/turn_system.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/game.dart';

class Enemy extends SpriteAnimationComponent with HasGameRef<MainGame> {
  
  final Map<CharacterAnimationState, SpriteAnimation> _animations = {};
  CharacterAnimationState _playerState = CharacterAnimationState.idleDown;
  bool _isMoving = false;
  
  Enemy({required super.position})
      : super(size: Vector2(32,32), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    _createAnimations();
  }

  void _createAnimations() async {
    Image? image = await game.images.load('animations/AxemanRed-walk-down.png');
    Map<String, dynamic> jsonData = await game.assets
        .readJson('images/animations/AxemanRed-walk-down.json');
    _animations[CharacterAnimationState.walkingDown] =
        SpriteAnimation.fromAsepriteData(image, jsonData);

    image = await game.images.load('animations/AxemanRed-walk-up.png');
    jsonData =
        await game.assets.readJson('images/animations/AxemanRed-walk-up.json');
    _animations[CharacterAnimationState.walkingUp] =
        SpriteAnimation.fromAsepriteData(image, jsonData);

    image = await game.images.load('animations/AxemanRed-walk-left.png');
    jsonData = await game.assets
        .readJson('images/animations/AxemanRed-walk-left.json');
    _animations[CharacterAnimationState.walkingLeft] =
        SpriteAnimation.fromAsepriteData(image, jsonData);

    image = await game.images.load('animations/AxemanRed-walk-right.png');
    jsonData = await game.assets
        .readJson('images/animations/AxemanRed-walk-right.json');
    _animations[CharacterAnimationState.walkingRight] =
        SpriteAnimation.fromAsepriteData(image, jsonData);

    image = await game.images.load('animations/AxemanRed-idle-up.png');
    jsonData =
        await game.assets.readJson('images/animations/AxemanRed-idle-up.json');
    _animations[CharacterAnimationState.idleUp] =
        SpriteAnimation.fromAsepriteData(image, jsonData);

    image = await game.images.load('animations/AxemanRed-idle-down.png');
    jsonData = await game.assets
        .readJson('images/animations/AxemanRed-idle-down.json');
    _animations[CharacterAnimationState.idleDown] =
        SpriteAnimation.fromAsepriteData(image, jsonData);

    image = await game.images.load('animations/AxemanRed-idle-left.png');
    jsonData = await game.assets
        .readJson('images/animations/AxemanRed-idle-left.json');
    _animations[CharacterAnimationState.idleLeft] =
        SpriteAnimation.fromAsepriteData(image, jsonData);

    image = await game.images.load('animations/AxemanRed-idle-right.png');
    jsonData = await game.assets
        .readJson('images/animations/AxemanRed-idle-right.json');
    _animations[CharacterAnimationState.idleRight] =
        SpriteAnimation.fromAsepriteData(image, jsonData);

    _stateChanged(CharacterAnimationState.idleDown);    
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  void takeHit(double damage) {

  }


  void faceDirection(Direction direction) {
    switch (direction) {
      case Direction.up:
        _stateChanged(CharacterAnimationState.idleUp);
        break;
      case Direction.down:
        _stateChanged(CharacterAnimationState.idleDown);
        break;
      case Direction.left:
        _stateChanged(CharacterAnimationState.idleLeft);
        break;
      case Direction.right:
        _stateChanged(CharacterAnimationState.idleRight);
      default:
    } 
  }

  void move(Direction direction) {
    if(_isMoving) {
      return;
    }
    _isMoving = true;
    final distance = Vector2(0, 0);
    switch (direction) {
      case Direction.up:
        distance.y -= TILESIZE;
        _stateChanged(CharacterAnimationState.walkingUp);
        break;
      case Direction.down:
        distance.y += TILESIZE;
        _stateChanged(CharacterAnimationState.walkingDown);
        break;
      case Direction.left:
        distance.x -= TILESIZE;
        _stateChanged(CharacterAnimationState.walkingLeft);
        break;
      case Direction.right:
        distance.x += TILESIZE;
        _stateChanged(CharacterAnimationState.walkingRight);
        break;
      case Direction.none:
    }

    final lastPos = position.clone();

    final move = MoveEffect.by(
      distance,
      EffectController(duration: .24),
      onComplete: () {
        // snap to grid. issue with moveTo/moveBy not being perfect...
        position = lastPos + distance;
        final tilePos = posToTile(position);
        game.overworld?.steppedOnTile(tilePos);
        // final tile = posToTile(position);
        // UI.debugLabel.text = '${tile.x}, ${tile.y}';
        _stateChanged(CharacterAnimationState.beginIdle);
        _isMoving = false;
        game.overworld!.moveNextEnemy();
      },
    );
    move.removeOnFinish = true;

    add(move);
  }

  void _stateChanged(CharacterAnimationState st) {
    if (st == CharacterAnimationState.beginIdle) {
      switch (_playerState) {
        case CharacterAnimationState.walkingUp:
          animation = _animations[CharacterAnimationState.idleUp];
          return;
        case CharacterAnimationState.walkingDown:
          animation = _animations[CharacterAnimationState.idleDown];
          return;
        case CharacterAnimationState.walkingLeft:
          animation = _animations[CharacterAnimationState.idleLeft];
          return;
        case CharacterAnimationState.walkingRight:
          animation = _animations[CharacterAnimationState.idleRight];
          return;
        case CharacterAnimationState.beginIdle:
        case CharacterAnimationState.idleDown:
        case CharacterAnimationState.idleUp:
        case CharacterAnimationState.idleLeft:
        case CharacterAnimationState.idleRight:
        case CharacterAnimationState.attacking:
        case CharacterAnimationState.takingDamage:
      }
    } else {
      animation = _animations[st];
      _playerState = st;
    }
  }
}

