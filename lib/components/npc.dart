import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_game/components/melee_character.dart';
import 'package:flame_game/control/enum/character_state.dart';

class NPC extends MeleeCharacter {
  final NpcData data;
  NPC(this.data) : super();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    position = data.position;
  }

  @override
  Future<void> buildAnimations() async {
    if (data.animationJsonFile.isNotEmpty) {
      final json = await game.assets.readJson(data.animationJsonFile);
      final imageFilename = json['imageFile'] ?? '';
      final image = await game.images.load(imageFilename);

      for (final state in CharacterAnimationState.values) {
        if (json.containsKey(state.name)) {
          animations[state] = animationFromJson(image, json, state.name);
        }
      }

      animation = animations[CharacterAnimationState.idleDown];
    } else if (data.spriteFile.isNotEmpty) {}
  }
}

class NpcData {
  String speech = '';
  String name = '';
  String shopJsonFile = '';
  String animationJsonFile = '';
  String spriteFile = '';
  Vector2 position = Vector2.zero();
}
