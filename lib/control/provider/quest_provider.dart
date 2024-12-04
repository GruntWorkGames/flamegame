import 'package:karas_quest/control/json/quest.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final questListProvider = StateNotifierProvider<QuestListProvider, List<Quest>>((ref) {
  return QuestListProvider();
});

class QuestListProvider extends StateNotifier<List<Quest>>{
  QuestListProvider() : super([]);

  void set(List<Quest> quests) {
    state = quests;
  }

  void add(Quest quest) {
    state.add(quest);
  }
}
