import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/enum/ui_view_type.dart';
import 'package:karas_quest/control/provider/dialog_provider.dart';
import 'package:karas_quest/control/provider/ui_provider.dart';

class DialogView extends ConsumerWidget {
  final bool showCloseButton;
  const DialogView({super.key, this.showCloseButton = true});

  @override
  Widget build(Object context, WidgetRef ref) {

    final dialog = ref.watch(dialogProvider);
    // create title box
    const titleStyle = TextStyle(fontSize: 18, color: Colors.white);
    final titleText = Padding(padding: const EdgeInsets.all(5), child: Text(dialog.title, style: titleStyle));
    final decoration = BoxDecoration(borderRadius: BorderRadius.circular(borderRadius), border: Border.all(color: borderColor, width: borderWidth), color: mainColor);
    final title = Container(decoration: decoration, child: titleText);

    // create message box
    final mText = Padding(padding: const EdgeInsets.all(5), child: Text(dialog.message, style: titleStyle));
    final box = ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400), child: mText);
    final message = Container(decoration: decoration, child: box);

    const spacer = SizedBox(height: 4);

    final closeBtnContainer = showCloseButton 
    ? InkWell(
      onTap: () => ref.read(uiProvider.notifier).set(UIViewDisplayType.game), 
      child: Padding(padding: const EdgeInsets.only(top: 30), 
        child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
        boxShadow: const [BoxShadow(offset: Offset(0, 1), blurRadius: 5, spreadRadius: 1, color: Colors.black45)],
        borderRadius: BorderRadius.circular(30), 
        color: Colors.grey[600]), 
        child: const Icon(Icons.close, size: 24, color: Colors.white))))
    : const SizedBox.shrink();

    final column = Column(mainAxisAlignment: MainAxisAlignment.center, children: [title, spacer, message, closeBtnContainer]);
    final blur =  BackdropFilter(filter:ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Center(child: column));
    return blur;
  }
}