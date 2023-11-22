import 'package:flame/effects.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:vector_math/vector_math_64.dart';

class Enemy extends MeleeCharacter {
  
  Enemy();

  @override
  Future<void> onLoad() async {
    position = position;
    health = 30;
    super.onLoad();  
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onMoveCompleted(Vector2 newTile) {
    game.overworld!.moveNextEnemy();
  }

  void takeHit(int damage, Function onComplete, Function onKilled) {
    health -= damage;

    final flicker = OpacityEffect.fadeOut(EffectController(repeatCount: 2, duration: 0.1, alternate: true), onComplete: (){
      if(health <= 0) {
        onKilled();
      } else {
        onComplete();
      }
    });
    flicker.removeOnFinish = true;
    add(flicker);
  }
}

