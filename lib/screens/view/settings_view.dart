import 'package:flame_game/control/constants.dart';
import 'package:flame_game/screens/view/settings/control_style_setting.dart';
import 'package:flame_game/screens/view/settings/fx_setting.dart';
import 'package:flame_game/screens/view/settings/music_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const textStyle = TextStyle(fontSize: 18, color: Colors.white);
    const title = Padding(padding: EdgeInsets.all(7), child: Text('Settings', style: textStyle));
    final titleContainer = Padding(padding: const EdgeInsets.only(bottom: 1), child: Container(decoration: boxDecoration, child: title));

    final cells = <Widget>[];
    
    final control = Padding(padding: const EdgeInsets.only(bottom:10), child: ControlStyleSetting());
    final row = Row(mainAxisAlignment: MainAxisAlignment.center, children: [control]);
    final controlCell = _cell(context, 'Control Type', row);
    cells.add(controlCell);

    const music = Padding(padding: EdgeInsets.only(bottom:10), child: MusicSetting());
    const musicRow = Row(mainAxisAlignment: MainAxisAlignment.center, children: [music]);
    final musicCell = _cell(context, 'Music Volume', musicRow);
    cells.add(musicCell);

    const fx = Padding(padding: EdgeInsets.only(bottom:10), child: FxSetting());
    const fxRow = Row(mainAxisAlignment: MainAxisAlignment.center, children: [fx]);
    final fxCell = _cell(context, 'FX Volume', fxRow);
    cells.add(fxCell);

    final col = Column(mainAxisAlignment: MainAxisAlignment.center, 
      children: [...cells]);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height / 2;
    final box = Container(width: width, height: height, child:
      SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: col));
    final content = Column(mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        titleContainer, 
        box
      ]);
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