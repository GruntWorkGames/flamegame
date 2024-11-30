import 'package:flame_game/components/game.dart';
import 'package:flame_game/control/constants.dart';
import 'package:flame_game/control/json/quest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestView extends ConsumerWidget {
  final Quest quest;
  final MainGame game;
  const QuestView(this.quest, this.game, {super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = Text(quest.title, style: titleStyle, textAlign: TextAlign.center);
    final text = Text(quest.text, textAlign: TextAlign.center);
    var isDone = false;
    final objectives = quest.objectives.map((objective) {
      isDone = (objective.currentCount / objective.countNeeded) == 1;
      final doneString = isDone ? '- Done' : '';
      final progressString = '${objective.title}      ${objective.currentCount} / ${objective.countNeeded} $doneString';
      final progress = Text(progressString, textAlign: TextAlign.center);
      return Row(mainAxisAlignment: MainAxisAlignment.center,children:[Column(children: [progress])]);
    }).toList();
    final buttonStyle = ButtonStyle(elevation: WidgetStateProperty.resolveWith<double>((states) {
      if(states.contains(WidgetState.pressed)) {
        return 0;
      } else {
        return 5;
      }
    }), backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if(states.contains(WidgetState.pressed)) {
        return mainColor;
      } else {
        return borderColor;
      }
    }));
    const buttonTextStyle = TextStyle(fontSize: 16, color: Colors.white);
    const completeBtnText = Padding(padding: EdgeInsets.all(5), child: Text('Complete', style: buttonTextStyle));
    final button = ElevatedButton(style: buttonStyle, child: completeBtnText, onPressed: (){
      game.playerCompletedQuest(quest);
    });
    final buttonRow = isDone ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [button]) : const SizedBox.shrink();
    final buttonPadding = Padding(padding: const EdgeInsets.only(top: 20), child: buttonRow);
    return Column(children: [title, text, const SizedBox(height: 10), ...objectives, buttonPadding]);
  }
}