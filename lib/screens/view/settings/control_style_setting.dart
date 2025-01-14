import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karas_quest/control/enum/control_style.dart';
import 'package:karas_quest/control/provider/control_style_provider.dart';


class ControlStyleSetting extends ConsumerWidget {
  final buttonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if(states.contains(WidgetState.selected)) {
        return Colors.grey[400]!;
      } else {
        return Colors.grey[700]!;
      }
    }),
  );

  ControlStyleSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(controlStyleState);
    return SegmentedButton<ControlStyle>(
      style: buttonStyle,
      segments: const <ButtonSegment<ControlStyle>>[
        ButtonSegment<ControlStyle>(
            value: ControlStyle.directional,
            label: Text('Directional Pad')),
        ButtonSegment<ControlStyle>(
            value: ControlStyle.swipe,
            label: Text('Swipe Direction')),
      ],
      selected: <ControlStyle>{state},
      onSelectionChanged: (Set<ControlStyle> newSelection) {
        ref.read(controlStyleState.notifier).state = newSelection.first;
      },
    );
  }
}
