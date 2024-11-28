import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/control/constants.dart';
import 'package:flame_game/control/enum/character_state.dart';
import 'package:flame_game/control/enum/item_type.dart';
import 'package:flame_game/control/json/item.dart';
import 'package:flame_game/control/objects/tile.dart' as k;

class Enemy extends MeleeCharacter {
  int experienceYield = 10;
  final String animationFile;
  Enemy(this.animationFile);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    data.health = 6;
    weapon = Item();
    weapon.type = ItemType.weapon;
    weapon.value = 3;
    moveDuration = 0.15;
    data.gold = 4;
  }

  @override
  Future<void> buildAnimations() async {
    final json = await game.assets.readJson(animationFile);
    final imageFilename = json['imageFile'] as String? ?? '';
    final image = await game.images.load(imageFilename);

    for (final state in CharacterAnimationState.values) {
      if(json.containsKey(state.name)) {
        animations[state] = animationFromJson(image, json, state.name);
      }
    }

    animation = animations[CharacterAnimationState.idleDown];
  }

  @override
  void onMoveCompleted(k.Tile newTile) {
    game.mapRunner!.moveNextEnemy();
    data.tilePosition = posToTile(position);
  }
}
