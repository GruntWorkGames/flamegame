import 'package:flame_game/constants.dart';
import 'package:flame_game/screens/view/control_style_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyle = TextStyle(fontSize: 18, color: Colors.white);
    final title = Padding(padding: EdgeInsets.all(7), child: Text('Settings', style: textStyle));
    final titleContainer = Container(decoration: boxDecoration, child: title);

    final cells = [];
    
    final control = Padding(padding: EdgeInsets.only(top:10), child: ControlStyleSetting());
    final row = Row(mainAxisAlignment: MainAxisAlignment.center, children: [control]);
    final controlCell = _cell(context, 'Control Type', row);
    cells.add(controlCell);

    final col = Column(mainAxisAlignment: MainAxisAlignment.center, 
      children: [...cells]);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height / 2;
    final box = Container(width: width, height: height, child:
      SingleChildScrollView(physics: AlwaysScrollableScrollPhysics(), child: col));
    final content = Column(mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        titleContainer, 
        box
      ]);
    return Center(child: content);
  }

  Widget _cell(BuildContext context, String title, Row row) {
    final width = MediaQuery.of(context).size.width;
    final titleText = Row(mainAxisAlignment: MainAxisAlignment.start, 
    children:[
      Padding(padding:EdgeInsets.only(left: 20, top: 10), 
        child: Text(title, style: titleStyle))
      ]);
    final column = Column( children: [titleText, row]);
    return Padding(padding: EdgeInsets.fromLTRB(10, 2, 10, 0), 
    child: Container(width: width, height: 90, 
      decoration: boxDecoration, child: column));
  }
}