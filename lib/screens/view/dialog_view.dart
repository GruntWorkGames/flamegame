import 'dart:ui';

import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/provider/dialog_provider.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DialogView extends ConsumerWidget {
  @override
  Widget build(Object context, WidgetRef ref) {
    final dialog = ref.watch(dialogProvider);
    // create title box
    final titleStyle = TextStyle(fontSize: 18, color: Colors.white);
    final titleText = Padding(padding: EdgeInsets.all(5), child: Text(dialog.title, style: titleStyle));
    final decoration = BoxDecoration(border: Border.all(color: Color.fromARGB(255, 173, 91, 20), width: 4), color: Color.fromARGB(255, 82, 41, 4));
    final title = Container(decoration: decoration, child: titleText);

    // create message box
    final mText = Padding(padding: EdgeInsets.all(5), child: Text(dialog.message, style: titleStyle));
    final box = ConstrainedBox(constraints: BoxConstraints(maxWidth: 400, maxHeight: 400), child: mText);
    final message = Container(decoration: decoration, child: box);

    const spacer = SizedBox(height: 4);
    final column = Column(mainAxisAlignment: MainAxisAlignment.center, children: [title, spacer, message]);
        // game.ref.read(uiProvider.notifier).set(UIViewDisplayType.dialog);
    final blur =  BackdropFilter(filter:ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Center(child: column));
    return blur;
  }
}