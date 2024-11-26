import 'package:flame_game/components/game.dart';
import 'package:flame_game/control/json/character_data.dart';
import 'package:flutter/foundation.dart';

class GameEventListener {
  final CharacterData data;
  final MainGame game;

  GameEventListener(this.game, this.data);

  void onEvent(String event, String value) {
    switch(event) {
    case 'talk_to':
      _onTalkToEvent(value);
      break;
    case 'killed_enemy':
      break;  
    default:
      debugPrint('unknown event'); 
    }
  }
  
  void _onTalkToEvent(String value) {
    final event = 'talk_to_$value';
    for(final quest in data.quests) {
      for(final objective in quest.objectives) {
        if(event == objective.listenEvent) {
          if(objective.currentCount < objective.countNeeded) {
            objective.currentCount += 1;
          }

          if(objective.countNeeded == objective.currentCount) {
            debugPrint('quest completed');

            // remove quest from log
            // give reward
          }
        }
      }
    }
  }
}