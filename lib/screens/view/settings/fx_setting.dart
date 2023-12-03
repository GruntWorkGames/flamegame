import 'package:flame_game/control/provider/fx_slider_value_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FxSetting extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sliderValue = ref.watch(fxSliderValueState);
    final slider = Slider(max: 100, min: 0, value: sliderValue, onChanged: (value) {
      ref.read(fxSliderValueState.notifier).set(value);
    });
    final themeData = SliderThemeData(
      activeTrackColor: Colors.white,
      inactiveTrackColor: Colors.grey[700],
      thumbColor: Colors.grey[500]
    );
    final theme = SliderTheme(data: themeData, child: slider);

    return Container(width: 300, child: theme);
  }
}