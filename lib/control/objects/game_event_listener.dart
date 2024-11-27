import 'package:flame_game/components/game.dart';
import 'package:flame_game/control/json/character_data.dart';
import 'package:flame_game/control/provider/quest_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameEventListener {
  final CharacterData data;
  final MainGame game;

  GameEventListener(this.game, this.data);

  void onEvent(String event, String value, WidgetRef? ref) {
    switch(event) {
    case 'talk_to':
      _onTalkToEvent(value, ref);
      break;
    case 'killed_enemy':
      break;  
    default:
      debugPrint('unknown event'); 
    }
  }
  
  void _onTalkToEvent(String value, WidgetRef? ref) {
    final event = 'talk_to_$value';
    for(final quest in data.quests) {
      for(final objective in quest.objectives) {
        if(event == objective.listenEvent) {
          if(objective.currentCount < objective.countNeeded) {
            objective.currentCount += 1;
          }

          if(objective.countNeeded == objective.currentCount) {
            debugPrint('quest completed');
            quest.isComplete = true;
            // remove quest from log
            // give reward
            
          }
        }
      }
    }
    ref?.read(questListProvider.notifier).set(game.player.data.quests);
  }
}