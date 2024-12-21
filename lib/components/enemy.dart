import 'package:karas_quest/components/melee_character.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/enum/character_state.dart';
import 'package:karas_quest/control/enum/item_type.dart';
import 'package:karas_quest/control/json/character_data.dart';
import 'package:karas_quest/control/json/item.dart';
import 'package:karas_quest/control/objects/tile.dart' as k;

class Enemy extends MeleeCharacter {
  int experienceYield = 10;

  Enemy(String animationFile) {
    data.animationFile = animationFile;
  }

  Enemy.fromCharacterData(CharacterData character) {
    data = character;
    position = tileToPos(data.tilePosition);
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['animationFile'] = data.animationFile;
    return map;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    data.health = 6;
    weapon = Item();
    weapon.type = ItemType.weapon;
    weapon.value = 3;
    moveDuration = 0.15;
    data.gold = 4;
    if(data.tilePosition.x != 0 && data.tilePosition.y != 0) {
      position = tileToPos(data.tilePosition);
    }
  }

  @override
  Future<void> buildAnimations() async {
    final json = await game.assets.readJson(data.animationFile);
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
