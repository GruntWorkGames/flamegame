import 'package:karas_quest/control/enum/control_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final controlStyleState = StateNotifierProvider<ControlStyleState, ControlStyle>((ref) {
  return ControlStyleState();
});

class ControlStyleState extends StateNotifier<ControlStyle> {
  ControlStyleState() : super(ControlStyle.directional);

  @override
  set state(ControlStyle type) {
    state = type;
  }
}