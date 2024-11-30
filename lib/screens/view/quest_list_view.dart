import 'package:flame_game/components/game.dart';
import 'package:flame_game/control/constants.dart';
import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/provider/quest_provider.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flame_game/screens/view/quest_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestListView extends ConsumerWidget{
  final MainGame game;
  const QuestListView(this.game, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questListProvider);
    const textStyle = TextStyle(fontSize: 18, color: Colors.white);
    const title = Padding(padding: EdgeInsets.all(7), child: Text('Quests', style: textStyle));
    final titleContainer = Padding(padding: const EdgeInsets.only(bottom: 1), child: Container(decoration: boxDecoration, child: title));

    final cells = <Widget>[];
    for(final quest in quests) {
      final questItem = Expanded(child: Padding(padding: const EdgeInsets.only(bottom:10), child: QuestView(quest, game)));
      final row = Row(mainAxisAlignment: MainAxisAlignment.center, children: [questItem]);
      final questCell = _cell(context, '', row);
      cells.add(questCell);
    }

    final col = Column(mainAxisAlignment: MainAxisAlignment.center, children: cells);
    final scroll = SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: col);
    
    final closeBtnContainer = InkWell(
      onTap: () => ref.read(uiProvider.notifier).set(UIViewDisplayType.game), 
      child: Padding(padding: const EdgeInsets.only(top: 30), 
        child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
        boxShadow: const [BoxShadow(offset: Offset(0, 1), blurRadius: 5, spreadRadius: 1, color: Colors.black45)],
        borderRadius: BorderRadius.circular(30), 
        color: Colors.grey[600]), 
        child: const Icon(Icons.close, size: 24, color: Colors.white))));  

    final content = Column(mainAxisAlignment: MainAxisAlignment.center, children: [titleContainer, scroll, closeBtnContainer]);
    return Center(child: content);
  }

  Widget _cell(BuildContext context, String title, Row row) {
    final width = MediaQuery.of(context).size.width;
    final titleText = Row(children:[
      Padding(padding:const EdgeInsets.only(left: 20, top: 10), 
        child: Text(title, style: titleStyle))
      ]);
    final column = Padding(padding: const EdgeInsets.only(bottom: 10), child: Column( children: [titleText, row]));
    return Padding(padding: const EdgeInsets.fromLTRB(10, 2, 10, 0), 
    child: Container(width: width, 
      decoration: boxDecoration, child: column));
  }
}