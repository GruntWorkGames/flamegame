
import 'dart:convert';

import 'package:flutter/services.dart';

class Quest {
  String title = '';
  String text = '';
  String id = '';
  List<QuestObjective> objectives = [];

  Quest();

  Quest.fromMap(Map<String, dynamic> map) {
    title = map['title'] as String? ?? '';
    text = map['text'] as String? ?? '';
    id = map['id'] as String? ?? '';

    final objList = map['objectives'] as List<dynamic>? ?? [];
    for(final obj in objList) {
      final objNode = obj as Map<String, dynamic>? ?? {};
      objectives.add(QuestObjective.fromMap(objNode));
    }
  }

  Future<void> loadDefaultQuest() async {
    final questJson = await rootBundle.loadString('assets/json/quests/first_quest.json');
    final questMap = jsonDecode(questJson) as Map<String, dynamic>? ?? {};
    title = questMap['title'] as String? ?? '';
    text = questMap['text'] as String? ?? '';
    id = questMap['id'] as String? ?? '';
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
  int countNeeded = 0;
  int currentCount = 0;

  QuestObjective();

  QuestObjective.fromMap(Map<String, dynamic> map) {
    title = map['title'] as String? ?? '';
    listenEvent = map['listenEvent'] as String? ?? '';
    countNeeded = map['countNeeded'] as int? ?? 0;
    currentCount = map['currentCount'] as int? ?? 0;
  }
}

class CompletedQuest {
  String id = '';
  CompletedQuest.fromMap(Map<String, dynamic> map) {
    id = map['id'] as String? ?? 'first_quest';
  }
}