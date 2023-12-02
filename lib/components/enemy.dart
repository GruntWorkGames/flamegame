import 'package:flame/effects.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/control/enum/character_state.dart';
import 'package:flame_game/control/json/item.dart';
import 'package:vector_math/vector_math_64.dart';

class Enemy extends MeleeCharacter {
  Enemy();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    data.health = 6;
    weapon = Item();
    weapon.value = 1;
    moveDuration = 0.15;
    data.gold = 4;
  }

  @override
  Future<void> buildAnimations() async {
    final json = await game.assets.readJson('json/club_goblin.json');
    final imageFilename = json['imageFile'] ?? '';
    final image = await game.images.load(imageFilename);

    for (final state in CharacterAnimationState.values) {
      if(json.containsKey(state.name)) {
        animations[state] = animationFromJson(image, json, state.name);
      }
    }

    animation = animations[CharacterAnimationState.idleDown];
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onMoveCompleted(Vector2 newTile) {
    game.overworld!.moveNextEnemy();
  }

  @override
  void takeHit(int damage, Function onComplete, Function onKilled) {
    data.health -= damage;

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
}
