import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/screens/view/debug/enemies_enabled_provider.dart';

class DebugView extends ConsumerWidget {

  final MainGame game;
  DebugView(this.game, {super.key});

  final buttonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if(states.contains(WidgetState.selected)) {
        return Colors.grey[400]!;
      } else {
        return Colors.grey[700]!;
      }
    }),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(enemiesEnabled);
    const textStyle = TextStyle(fontSize: 18, color: Colors.white);
    const title = Padding(padding: EdgeInsets.all(7), child: Text('Enemy Spawning', style: textStyle));
    final titleContainer = Padding(padding: const EdgeInsets.only(bottom: 1), child: Container(decoration: boxDecoration, child: title));
    final enemiesEnabledControl = SegmentedButton<bool>(
      style: buttonStyle,
      segments: const <ButtonSegment<bool>>[
        ButtonSegment<bool>(
            value: true,
            label: Text('enabled')),
        ButtonSegment<bool>(
            value: false,
            label: Text('disabled')),
      ],
      selected: <bool>{value},
      onSelectionChanged: (Set<bool> newSelection) {
        ref.read(enemiesEnabled.notifier).set(newSelection.first);
      },
    );

    const vSpacer = SizedBox(height: 40);

    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [titleContainer, enemiesEnabledControl, vSpacer, _debugCommandView(context)],),);
  }

  Widget _debugCommandView(BuildContext context) {
    final debugTextFieldController = TextEditingController();
    final width = MediaQuery.of(context).size.width / 2;
    const inputDecoration = InputDecoration(
      hintText: 'Enter command',
      border: OutlineInputBorder());
      final containerDecoration = BoxDecoration(
      color: mainColor, 
      border: Border.all(
        color: borderColor, 
        width: borderWidth), 
        borderRadius: BorderRadius.circular(borderRadius));
    final button = Container(decoration: containerDecoration, child:IconButton(color: mainColor, onPressed: (){
      game.command(debugTextFieldController.text, context);
    }, icon: const Icon(Icons.check_circle_outline_outlined, size: 34, color: Colors.white)));
    
    final textField = Container(decoration: containerDecoration, width: width, child: TextField(
      controller: debugTextFieldController,
      decoration: inputDecoration, 
      cursorColor: Colors.white,));
    const spacer = SizedBox(width: 10);
    return Center(child:Row(mainAxisAlignment: MainAxisAlignment.center, 
    children: [textField, spacer, button]));
  }
}