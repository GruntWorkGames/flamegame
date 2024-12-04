import 'package:karas_quest/components/melee_character.dart';
import 'package:karas_quest/control/enum/ui_view_type.dart';
import 'package:karas_quest/control/json/quest.dart';
import 'package:karas_quest/control/provider/quest_provider.dart';
import 'package:karas_quest/control/provider/ui_provider.dart';

class PlayerComponent extends MeleeCharacter {
  PlayerComponent();

  bool isEligibleForQuest(Quest quest) {
    final completedQuestIds = game.player.data.completedQuests.map((e) {
      return e.id; 
    });
    
    for(final questId in quest.requiredQuestIds) {
      if(!completedQuestIds.contains(questId)) {
        return false;
      }
    }
    
    final level = game.player.data.level;
    return level >= quest.requiredLevel;
  }

  void acceptQuest(Quest quest) {
    data.quests.add(quest);
    game.ref?.read(uiProvider.notifier).set(UIViewDisplayType.game);
    game.ref?.read(questListProvider.notifier).set([...data.quests]);
    game.save();
  }
}