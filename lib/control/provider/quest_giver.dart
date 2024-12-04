import 'package:karas_quest/control/json/quest.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final questGiver = StateNotifierProvider<QuestGiverState, List<Quest>>((ref) {
  return QuestGiverState();
});

class QuestGiverState extends StateNotifier<List<Quest>> {
  QuestGiverState() : super([]);

  void set(List<Quest> quests) {
    state = quests;
  }
}


final questGiverSelectedQuest = StateNotifierProvider<QuestGiverSelectedQuestState, Quest>((ref) {
  return QuestGiverSelectedQuestState();
});

class QuestGiverSelectedQuestState extends StateNotifier<Quest> {
  QuestGiverSelectedQuestState() : super(Quest());

  void set(Quest quests) {
    state = quests;
  }
}