import 'package:flame_game/control/enum/control_style.dart';
import 'package:flame_game/control/provider/control_style_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


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
        ref.read(controlStyleState.notifier).set(newSelection.first);
      },
    );
  }
}
