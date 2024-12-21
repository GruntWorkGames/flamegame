import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/control/provider/quest_provider.dart';

class GameEventListener {
  final MainGame game;

  GameEventListener(this.game);

  void onEvent(String event, String target, WidgetRef? ref) {
    switch(event) {
    case 'talk_to':
      _genericObjective(target, ref);
    case 'killed':
      _onKilledEvent(target, ref);
    case 'buy':
      _genericObjective(target, ref);
    default:
      debugPrint('unknown event'); 
    }
  }
  
  void _genericObjective(String target, WidgetRef? ref) {
    for(final quest in game.saveFile.activeQuests) {
      for(final objective in quest.objectives) {
        if(target == objective.target) {
          if(objective.currentCount < objective.countNeeded) {
            objective.currentCount += 1;
          } else if(objective.currentCount == objective.countNeeded) {
            quest.isComplete = true;
          }
        }
      }
    }

    ref?.read(questListProvider.notifier).set(game.saveFile.activeQuests);
  }

  void _onKilledEvent(String target, WidgetRef? ref) {
    for(final quest in game.saveFile.activeQuests) {
      for(final objective in quest.objectives) {
        final anyTarget = objective.target == 'any';
        if(anyTarget || target == objective.target) {
          if(objective.currentCount < objective.countNeeded) {
            objective.currentCount += 1;
          } else if(objective.currentCount == objective.countNeeded) {
            quest.isComplete = true;
          }
        }
      }
    }
  }
}