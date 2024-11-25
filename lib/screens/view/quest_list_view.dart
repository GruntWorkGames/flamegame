import 'package:flame_game/control/constants.dart';
import 'package:flame_game/control/provider/quest_provider.dart';
import 'package:flame_game/screens/view/quest_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestListView extends ConsumerWidget{
  const QuestListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questListProvider);
    const textStyle = TextStyle(fontSize: 18, color: Colors.white);
    const title = Padding(padding: EdgeInsets.all(7), child: Text('Quests', style: textStyle));
    final titleContainer = Padding(padding: const EdgeInsets.only(bottom: 1), child: Container(decoration: boxDecoration, child: title));

    final cells = <Widget>[];
    for(final quest in quests) {
      final questItem = Padding(padding: const EdgeInsets.only(bottom:10), child: QuestView(quest));
      final row = Row(mainAxisAlignment: MainAxisAlignment.center, children: [questItem]);
      final questCell = _cell(context, '', row);
      cells.add(questCell);
    }

    final col = Column(mainAxisAlignment: MainAxisAlignment.center, children: cells);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height / 2;
    final box = Container(width: width, height: height, child:SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: col));
    final content = Column(mainAxisAlignment: MainAxisAlignment.center, children: [titleContainer, box]);
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