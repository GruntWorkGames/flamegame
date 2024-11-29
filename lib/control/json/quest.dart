import 'dart:convert';
import 'package:flame_game/control/json/quest_reward.dart';
import 'package:flutter/services.dart';

class Quest {
  String title = '';
  String text = '';
  String id = '';
  String completer = '';
  bool isComplete = false;
  int requiredLevel = 0;
  QuestReward reward = QuestReward();
  List<QuestObjective> objectives = [];
  List<String> requiredQuestIds = [];

  Quest();

  Quest.fromMap(Map<String, dynamic> map) {
    title = map['title'] as String? ?? '';
    text = map['text'] as String? ?? '';
    id = map['id'] as String? ?? '';
    isComplete = map['isComplete'] as bool? ?? false;
    completer = map['completer'] as String? ?? '';
    final rewardMap = map['reward'] as Map<String, dynamic>? ?? {};
    reward = QuestReward.fromMap(rewardMap);
    final objList = map['objectives'] as List<dynamic>? ?? [];
    for(final obj in objList) {
      final objNode = obj as Map<String, dynamic>? ?? {};
      objectives.add(QuestObjective.fromMap(objNode));
    }
    requiredLevel = map['requiredLevel'] as int? ?? 0;
    final questIdArry = map['requiredQuestIds'] as List<dynamic>? ?? [];
    for(final questId in questIdArry) {
      if(questId is String) {
        requiredQuestIds.add(questId);
      }
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'text': text,
      'id': id,
      'completer' : completer,
      'isComplete' : isComplete,
      'reward': reward.toMap(), // Assuming QuestReward has a toMap() method
      'objectives': objectives.map((objective) => objective.toMap()).toList(), // Assuming QuestObjective has a toMap() method
    };
  }

  Future<void> loadDefaultQuest() async {
    final questJson = await rootBundle.loadString('assets/json/quests/quest1.json');
    final questMap = jsonDecode(questJson) as Map<String, dynamic>? ?? {};
    title = questMap['title'] as String? ?? '';
    text = questMap['text'] as String? ?? '';
    id = questMap['id'] as String? ?? '';
    isComplete = questMap['isComplete'] as bool? ?? false;
    completer = questMap['completer'] as String? ?? '';
    final rewardMap = questMap['reward'] as Map<String, dynamic>? ?? {};
    reward = QuestReward.fromMap(rewardMap);
    final objList = questMap['objectives'] as List<dynamic>? ?? [];
    for(final obj in objList) {
      final objNode = obj as Map<String, dynamic>? ?? {};
      objectives.add(QuestObjective.fromMap(objNode));
    }
  }
}

class QuestObjective {
  String title = '';
  String listenEvent = '';
  String target = '';
  int countNeeded = 0;
  int currentCount = 0;

  QuestObjective();

  QuestObjective.fromMap(Map<String, dynamic> map) {
    title = map['title'] as String? ?? '';
    listenEvent = map['listenEvent'] as String? ?? '';
    target = map['target'] as String? ?? '';
    countNeeded = map['countNeeded'] as int? ?? 0;
    currentCount = map['currentCount'] as int? ?? 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'title' : title,
      'listenEvent' : listenEvent,
      'target' : target,
      'countNeeded' : countNeeded,
      'currentCount' : currentCount
    };
  }
}

class CompletedQuest {
  String id = '';
  CompletedQuest.fromMap(Map<String, dynamic> map) {
    id = map['id'] as String? ?? 'quest1';
  }
}