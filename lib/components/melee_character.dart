import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/image_composition.dart';
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

class MeleeCharacter extends SpriteAnimationComponent
    with HasGameRef<MainGame> {
  MeleeCharacter() : super(size: Vector2(TILESIZE, TILESIZE));
  bool isMoving = false;
  final Map<CharacterAnimationState, SpriteAnimation> _animations = {};
  CharacterAnimationState animationState = CharacterAnimationState.idleDown;
  List<MeleeWeapon> weapons = [];
  MeleeWeapon currentWeapon = DullShortSword();
  int health = 100;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
    _buildAnimations();
    actionFinished(CharacterAnimationState.idleDown);
  }

  Future<void> _buildAnimations() async {
    final image = await game.images.load('AxemanRed.png');
    final json = await game.assets.readJson('json/player_animations.json');

    final idleDown = _animationFromJson(image, json, 'idle_down');
    final idleUp = _animationFromJson(image, json, 'idle_up');
    final idleRight = _animationFromJson(image, json, 'idle_right');
    final idleLeft = _animationFromJson(image, json, 'idle_left');

    final walkDown = _animationFromJson(image, json, 'walk_down');
    final walkUp = _animationFromJson(image, json, 'walk_up');
    final walkRight = _animationFromJson(image, json, 'walk_right');
    final walkLeft = _animationFromJson(image, json, 'walk_left');

    final attackDown = _animationFromJson(image, json, 'attack_down');
    final attackUp = _animationFromJson(image, json, 'attack_up');
    final attackRight = _animationFromJson(image, json, 'attack_right');
    final attackLeft = _animationFromJson(image, json, 'attack_left');

    _animations[CharacterAnimationState.idleDown] = idleDown;
    _animations[CharacterAnimationState.idleUp] = idleUp;
    _animations[CharacterAnimationState.idleLeft] = idleLeft;
    _animations[CharacterAnimationState.idleRight] = idleRight;

    _animations[CharacterAnimationState.walkingDown] = walkDown;
    _animations[CharacterAnimationState.walkingLeft] = walkLeft;
    _animations[CharacterAnimationState.walkingUp] = walkUp;
    _animations[CharacterAnimationState.walkingRight] = walkRight;

    _animations[CharacterAnimationState.attackLeft] = attackLeft;
    _animations[CharacterAnimationState.attackRight] = attackRight;
    _animations[CharacterAnimationState.attackUp] = attackUp;
    _animations[CharacterAnimationState.attackDown] = attackDown;
  }

  SpriteAnimation _animationFromJson(Image image, Map<String, dynamic> json, String animName) {
    if(!json.containsKey(animName)) {
      return SpriteAnimation.fromFrameData(image, SpriteAnimationData([]));
    }
    final spriteSheet = SpriteSheet(
      image: image,
      srcSize: Vector2(16, 16),
    );
    final Map<String, dynamic> anim = json[animName];
    final List<SpriteAnimationFrameData> frames = [];
    final double stepTime = anim['timePerFrame'] ?? 0;
    if(anim.containsKey('frames')) {
      final List<dynamic> frameData = anim['frames'];
      for(final frame in frameData) {
        final x = frame['y'] ?? 0;
        final y = frame['x'] ?? 0;
        final f = spriteSheet.createFrameData(x, y, stepTime: stepTime);
        frames.add(f);
      }
    }
    return SpriteAnimation.fromFrameData(image, SpriteAnimationData(frames));
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