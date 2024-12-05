import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:karas_quest/components/melee_character.dart';
import 'package:karas_quest/control/enum/character_state.dart';
import 'package:karas_quest/control/json/npc_data.dart';
import 'package:karas_quest/control/json/quest.dart';

class NPC extends MeleeCharacter {
  final NpcData npc; 
  SpriteComponent? speechBubble;
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

    final image = await game.images.load('UiIcons.png');
    final spriteSheet = SpriteSheet(
      image: image,
      srcSize: Vector2(16, 16),
    );
    
    final sprite = spriteSheet.getSprite(3, 0);
    speechBubble = SpriteComponent(sprite: sprite, scale: Vector2(0.75, 0.75), position: Vector2(2, 0), anchor: Anchor.bottomLeft);
    add(speechBubble!);
    speechBubble?.setOpacity(0);
  }

  void setHasQuestIcon({bool shouldShow = false}) {
    final opacity = shouldShow ? 1.0 : 0.0;
    speechBubble?.setOpacity(opacity);
  }

  Future<List<Quest>> questsAvailable() async {
    final questsAvailable = <Quest>[];
    for(final questId in npc.questsAvailable) {
      final map = await game.assets.readJson('json/quests/$questId.json');
      final quest = Quest.fromMap(map);
      if(game.player.isEligibleForQuest(quest)) {
        questsAvailable.add(quest);
      }
    }
    return questsAvailable;
  }
}
