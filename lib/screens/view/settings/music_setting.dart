
import 'package:karas_quest/control/provider/music_slider_value_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicSetting extends ConsumerWidget {
  const MusicSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sliderValue = ref.watch(musicSliderValueState);
    final slider = Slider(max: 100, value: sliderValue, onChanged: (value) {
      ref.read(musicSliderValueState.notifier).set(value);
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