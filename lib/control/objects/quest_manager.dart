import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/control/enum/ui_view_type.dart';
import 'package:karas_quest/control/json/quest.dart';
import 'package:karas_quest/control/provider/quest_provider.dart';
import 'package:karas_quest/control/provider/ui_provider.dart';

class QuestManager {

  final MainGame game;
  QuestManager(this.game);

  bool isEligibleForQuest(Quest quest) {
    final completedQuestIds = game.saveFile.completedQuests.map((e) {
      return e.id; 
    });

    if(completedQuestIds.contains(quest.id)) {
      return false;
    }

    final currentQuests = game.saveFile.activeQuests.map((quest) {
      return quest.id;
    });

    if(currentQuests.contains(quest.id)) {
      return false;
    }
    
    for(final questId in quest.requiredQuestIds) {
      if(!completedQuestIds.contains(questId)) {
        return false;
      }
    }
    
    final level = game.player.data.level;
    return level >= quest.requiredLevel;
  }

  void acceptQuest(Quest quest) {
    game.mapRunner?.updateQuestIcons();
    game.saveFile.activeQuests.add(quest);
    game.ref?.read(uiProvider.notifier).set(UIViewDisplayType.game);
    game.ref?.read(questListProvider.notifier).set([...game.saveFile.activeQuests]);
    game.save();
  }

  void playerCompletedQuest(Quest quest) {
    quest.isComplete = true;
    game.saveFile.completedQuests.add(quest);
    game.saveFile.activeQuests.remove(quest);
    game.ref?.read(questListProvider.notifier).set([...game.saveFile.activeQuests]);
    game.mapRunner?.updateQuestIcons();
    game.save();
  }
}