import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/sprite.dart';
import 'package:flame_game/components/melee_attack_result.dart';
import 'package:flame_game/components/turn_system.dart';
import 'package:flame_game/control/constants.dart';
import 'package:flame_game/control/enum/character_state.dart';
import 'package:flame_game/control/enum/item_type.dart';
import 'package:flame_game/control/json/item.dart';
import 'package:flame_game/control/json/character_data.dart';
import 'package:flame_game/control/enum/direction.dart';
import 'package:flame_game/components/game.dart';
import 'package:flame_game/control/objects/tile.dart' as k;

class MeleeCharacter extends SpriteAnimationComponent
    with HasGameRef<MainGame> {
  MeleeCharacter() : super(size: Vector2(TILESIZE.toDouble(), TILESIZE.toDouble()));
  bool isMoving = false;
  final Map<CharacterAnimationState, SpriteAnimation> animations = {};
  CharacterAnimationState animationState = CharacterAnimationState.idleDown;
  Item weapon = Item()
    ..type = ItemType.weapon
    ..value = 3
    ..isEquipped = true;
  Item armor = Item()
    ..type = ItemType.armor
    ..value = 1
    ..isEquipped = true;
  double moveDuration = 0.24;
  CharacterData data = CharacterData();

  @override
  Future<void> onLoad() async {
    anchor = Anchor(0, 0.3);
    buildAnimations();
    actionFinished(CharacterAnimationState.idleDown);
  }

  Future<void> buildAnimations() async {
    final json = await game.assets.readJson('json/player_animations.json');
    final imageFilename = json['imageFile'] ?? '';
    final image = await game.images.load(imageFilename);
    for (final state in CharacterAnimationState.values) {
      if (json.containsKey(state.name)) {
        animations[state] = animationFromJson(image, json, state.name);
      }
    }

    animation = animations[CharacterAnimationState.idleDown];
  }

  SpriteAnimation animationFromJson(
      Image image, Map<String, dynamic> json, String animName) {
    if (!json.containsKey(animName)) {
      throw Exception('Missing Animation $animName');
    }
    final spriteSheet = SpriteSheet(
      image: image,
      srcSize: Vector2(16, 16),
    );
    final Map<String, dynamic> anim = json[animName];
    final List<SpriteAnimationFrameData> frames = [];
    final double stepTime = anim['timePerFrame'] ?? 0;
    if (anim.containsKey('frames')) {
      final List<dynamic> frameData = anim['frames'];
      for (final frame in frameData) {
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

  void onMoveCompleted(k.Tile newTile) {
    game.overworld?.steppedOnTile(newTile);
    isMoving = false;
    actionFinished(CharacterAnimationState.beginIdle);
    game.overworld!.turnSystem.updateState(TurnSystemState.playerFinished);
    data.tilePosition = posToTile(position);
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
        actionFinished(CharacterAnimationState.walkUp);
        break;
      case Direction.down:
        distance.y += TILESIZE;
        actionFinished(CharacterAnimationState.walkDown);
        break;
      case Direction.left:
        distance.x -= TILESIZE;
        actionFinished(CharacterAnimationState.walkLeft);
        break;
      case Direction.right:
        distance.x += TILESIZE;
        actionFinished(CharacterAnimationState.walkRight);
        break;
      case Direction.none:
    }
    final lastPos = position.clone();
    final move = MoveEffect.by(
      distance,
      EffectController(duration: moveDuration),
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
        case CharacterAnimationState.walkUp:
          animation = animations[CharacterAnimationState.idleUp];
          return;
        case CharacterAnimationState.walkDown:
          animation = animations[CharacterAnimationState.idleDown];
          return;
        case CharacterAnimationState.walkLeft:
          animation = animations[CharacterAnimationState.idleLeft];
          return;
        case CharacterAnimationState.walkRight:
          animation = animations[CharacterAnimationState.idleRight];
          return;
        case CharacterAnimationState.beginIdle:
        case CharacterAnimationState.idleDown:
        case CharacterAnimationState.idleUp:
        case CharacterAnimationState.idleLeft:
        case CharacterAnimationState.idleRight:
        case CharacterAnimationState.takingDamage:
        case CharacterAnimationState.attackDown:
          animation = animations[CharacterAnimationState.idleDown];
          return;
        case CharacterAnimationState.attackUp:
          animation = animations[CharacterAnimationState.idleUp];
          return;
        case CharacterAnimationState.attackLeft:
          animation = animations[CharacterAnimationState.idleLeft];
          return;
        case CharacterAnimationState.attackRight:
          animation = animations[CharacterAnimationState.idleRight];
          return;
      }
    } else {
      animation = animations[st];
      animationState = st;
    }
  }

  void playAttackDirectionAnim(Direction direction, Function onComplete) {
    switch (direction) {
      case Direction.down:
        animation = animations[CharacterAnimationState.attackDown];
        animationState = CharacterAnimationState.attackDown;
        break;
      case Direction.up:
        animation = animations[CharacterAnimationState.attackUp];
        animationState = CharacterAnimationState.attackUp;
        break;
      case Direction.left:
        animation = animations[CharacterAnimationState.attackLeft];
        animationState = CharacterAnimationState.attackLeft;
        break;
      case Direction.right:
        animation = animations[CharacterAnimationState.attackRight];
        animationState = CharacterAnimationState.attackRight;
        break;
      case Direction.none:
    }

    final emptyEffect = MoveByEffect(
        Vector2(0, 0), EffectController(duration: .5), onComplete: () {
      actionFinished(CharacterAnimationState.beginIdle);
      onComplete();
    });
    emptyEffect.removeOnFinish = true;
    add(emptyEffect);
  }

  bool attemptAttack() {
    final random = (Random().nextDouble() * 100) + 1;
    return random <= data.hit;
  }

  bool dodge() {
    final random = (Random().nextDouble() * 100) + 1;
    return random <= data.dodge;
  }

  double mitigatedDamage(double rawDamage) {
    final items = game.player.data.inventory;
    final armor = items.where((item) => item.type == ItemType.armor).toList().firstOrNull ?? Item();
    return max(0, rawDamage - armor.value);
  }

  // returns amount of damage done
  ({MeleeAttackResult result, double value}) takeHit(double damage, Function onComplete, Function onKilled) {
    if(dodge()) {
      onComplete();
      return (result: MeleeAttackResult.dodged, value: 0);
    }

    damage = mitigatedDamage(damage);
    data.health -= damage;
    if(damage > 0) {
      final flicker = OpacityEffect.fadeOut(
          EffectController(repeatCount: 2, duration: 0.1, alternate: true),
          onComplete: () {
        if (data.health <= 0) {
          onKilled();
        } else {
          onComplete();
        }
      });
      flicker.removeOnFinish = true;
      add(flicker);
    }
    return (result: MeleeAttackResult.success, value: damage);
  }

  void drinkPotion(Item item) {
    final newMax = data.health + item.value;
    if (newMax > data.maxHealth) {
      data.health = data.maxHealth;
    } else {
      data.health = newMax;
    }
  }

  // get a randomized damage calculated with stats and weapon
  double getDamage() {
    final r = Random().nextDouble() + 1;
    final str = data.str;
    final wepDmg = weapon.value;

    return ((wepDmg + str) * r).ceilToDouble();
  }
}

class PlayerComponent extends MeleeCharacter {
  PlayerComponent() {

  }
}
