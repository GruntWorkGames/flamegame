import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flame_game/components/dull_short_sword.dart';
import 'package:flame_game/components/melee_weapon.dart';
import 'package:flame_game/components/turn_system.dart';
import 'package:flame_game/components/ui.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/game.dart';

enum CharacterAnimationState {
  beginIdle,
  idleDown,
  idleUp,
  idleLeft,
  idleRight,
  walkingLeft,
  walkingRight,
  walkingUp,
  walkingDown,
  attackDown,
  attackUp,
  attackLeft,
  attackRight,
  takingDamage
}

class Player extends SpriteAnimationComponent
    with HasGameRef<MainGame> {
  Player() : super(size: Vector2(TILESIZE, TILESIZE));
  bool isMoving = false;
  final Map<CharacterAnimationState, SpriteAnimation> _animations = {};
  CharacterAnimationState animationState = CharacterAnimationState.idleDown;
  List<MeleeWeapon> weapons = [];
  MeleeWeapon currentWeapon = DullShortSword();
  int health = 100;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;

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

    _buildAnimations();

    actionFinished(CharacterAnimationState.idleDown);
  }

  Future<void> _buildAnimations() async {
    final spriteSheet = SpriteSheet(
      image: await game.images.load('AxemanRed.png'),
      srcSize: Vector2(16.0, 16.0),
    );

    final attackDown = SpriteAnimation.fromFrameData(
      await game.images.load('AxemanRed.png'), 
      SpriteAnimationData([
      spriteSheet.createFrameData(5, 1, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 2, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 3, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 4, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 5, stepTime: 0.1), // row, column
    ]));

    final attackUp = SpriteAnimation.fromFrameData(
      await game.images.load('AxemanRed.png'), 
      SpriteAnimationData([
      spriteSheet.createFrameData(5, 4, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 5, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 1, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 2, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 3, stepTime: 0.1), // row, column
    ]));

    final attackLeft = SpriteAnimation.fromFrameData(
      await game.images.load('AxemanRed.png'), 
      SpriteAnimationData([
      spriteSheet.createFrameData(5, 5, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 1, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 2, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 3, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 4, stepTime: 0.1), // row, column
    ]));

    final attackRight = SpriteAnimation.fromFrameData(
      await game.images.load('AxemanRed.png'), 
      SpriteAnimationData([
      spriteSheet.createFrameData(5, 3, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 4, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 5, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 1, stepTime: 0.1), // row, column
      spriteSheet.createFrameData(5, 2, stepTime: 0.1), // row, column
    ]));

    _animations[CharacterAnimationState.attackLeft] = attackLeft;
    _animations[CharacterAnimationState.attackRight] = attackRight;
    _animations[CharacterAnimationState.attackUp] = attackUp;
    _animations[CharacterAnimationState.attackDown] = attackDown;
  }

  void faceDirection(Direction direction) {
    switch (direction) {
      case Direction.up:
        actionFinished(CharacterAnimationState.idleUp);
        break;
      case Direction.down:
        actionFinished(CharacterAnimationState.idleDown);
        break;
      case Direction.left:
        actionFinished(CharacterAnimationState.idleLeft);
        break;
      case Direction.right:
        actionFinished(CharacterAnimationState.idleRight);
      default:
    } 
  }

  void onMoveCompleted(Vector2 newTile) {
    game.overworld?.steppedOnTile(newTile);
    isMoving = false;
    final tile = posToTile(position);
    UI.debugLabel.text = '${tile.x}, ${tile.y}';
    actionFinished(CharacterAnimationState.beginIdle);
    game.overworld!.turnSystem.updateState(TurnSystemState.playerFinished);
  }

  void move(Direction direction) {
    if (isMoving) {
      return;
    }
    isMoving = true;
    final distance = Vector2(0, 0);
    switch (direction) {
      case Direction.up:
        distance.y -= TILESIZE;
        actionFinished(CharacterAnimationState.walkingUp);
        break;
      case Direction.down:
        distance.y += TILESIZE;
        actionFinished(CharacterAnimationState.walkingDown);
        break;
      case Direction.left:
        distance.x -= TILESIZE;
        actionFinished(CharacterAnimationState.walkingLeft);
        break;
      case Direction.right:
        distance.x += TILESIZE;
        actionFinished(CharacterAnimationState.walkingRight);
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
        actionFinished(CharacterAnimationState.beginIdle);
        isMoving = false;
        onMoveCompleted(tilePos);
      },
    );
    move.removeOnFinish = true;

    add(move);
  }

  void actionFinished(CharacterAnimationState st) {
    if (st == CharacterAnimationState.beginIdle) {
      switch (animationState) {
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
        case CharacterAnimationState.takingDamage:
        case CharacterAnimationState.attackDown:
          animation = _animations[CharacterAnimationState.idleDown];
          return;
        case CharacterAnimationState.attackUp:
          animation = _animations[CharacterAnimationState.idleUp];
          return;
        case CharacterAnimationState.attackLeft:
          animation = _animations[CharacterAnimationState.idleLeft];
          return;
        case CharacterAnimationState.attackRight:
          animation = _animations[CharacterAnimationState.idleRight];
          return;
      }
    } else {
      animation = _animations[st];
      animationState = st;
    }
  }

  void attackDirection(Direction direction, Function onComplete) {
    switch(direction) {
        case Direction.down:
            animation = _animations[CharacterAnimationState.attackDown];
            animationState = CharacterAnimationState.attackDown;
            break;
        case Direction.up:
            animation = _animations[CharacterAnimationState.attackUp];
            animationState = CharacterAnimationState.attackUp;
            break;
        case Direction.left:
            animation = _animations[CharacterAnimationState.attackLeft];
            animationState = CharacterAnimationState.attackLeft;
            break;
        case Direction.right:
            animation = _animations[CharacterAnimationState.attackRight];
            animationState = CharacterAnimationState.attackRight;
            break;
      case Direction.none:
    }

    final emptyEffect = MoveByEffect(Vector2(0,0), EffectController(duration: .5), onComplete: () {
      actionFinished(CharacterAnimationState.beginIdle);
      onComplete();
    });
    emptyEffect.removeOnFinish = true;
    add(emptyEffect);
  }
}