import 'package:flame_game/control/enum/control_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final controlStyleState = StateNotifierProvider<ControlStyleState, ControlStyle>((ref) {
  return ControlStyleState();
});

class ControlStyleState extends StateNotifier<ControlStyle> {
  ControlStyleState() : super(ControlStyle.directional);

  void set(ControlStyle type) {
    state = type;
  }
}