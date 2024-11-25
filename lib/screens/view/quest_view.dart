import 'package:flame_game/control/constants.dart';
import 'package:flame_game/control/json/quest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestView extends ConsumerWidget {
  final Quest quest;
  const QuestView(this.quest, {super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = Text(quest.title, style: titleStyle);
    final text = Text(quest.text);
    final objectives = quest.objectives.map((objective) {
      final isComplete = (objective.currentCount / objective.countNeeded) == 1;
      final doneString = isComplete ? '- Done' : '';
      final progressString = '${objective.title}      ${objective.currentCount} / ${objective.countNeeded} $doneString';
      final progress = Text(progressString);
      return Row(children:[Column(children: [progress])]);
    }).toList();
    return Column(children: [title, text, ...objectives]);
  }
}