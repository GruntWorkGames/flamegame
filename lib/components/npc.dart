import 'dart:async';
import 'package:karas_quest/components/melee_character.dart';
import 'package:karas_quest/control/enum/character_state.dart';
import 'package:karas_quest/control/json/npc_data.dart';
import 'package:karas_quest/control/json/quest.dart';

class NPC extends MeleeCharacter {
  final NpcData npc;
  NPC(this.npc) : super();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    position = npc.position;
  }

  @override
  Future<void> buildAnimations() async {
    if (npc.animationJsonFile.isNotEmpty) {
      final json = await game.assets.readJson(npc.animationJsonFile);
      final imageFilename = json['imageFile'] ?? '';
      if(imageFilename is! String) {
        throw Exception('image file name is not String. it is ${imageFilename.runtimeType}');
      }
      final image = await game.images.load(imageFilename);

      for (final state in CharacterAnimationState.values) {
        if (json.containsKey(state.name)) {
          animations[state] = animationFromJson(image, json, state.name);
        }
      }

      animation = animations[CharacterAnimationState.idleDown];
    } else if (npc.spriteFile.isNotEmpty) {}
  }

  Future<List<Quest>> questsAvailable() async {
    final questsAvailable = <Quest>[];
    for(final questId in npc.questsAvailable) {
      final map = await game.assets.readJson('json/quests/$questId.json');
      final quest = Quest.fromMap(map);
      if(game.player.isEligibleForQuest(quest)) {
        print('player is eligible for $questId');
        questsAvailable.add(quest);
      }
    }
    return questsAvailable;
  }
}
