import 'package:flutter_riverpod/flutter_riverpod.dart';

final buttonOpacityProvider = StateNotifierProvider<ButtonOpacityState, double>((ref) {
  return ButtonOpacityState();
});

class ButtonOpacityState extends StateNotifier<double> {
  ButtonOpacityState() : super(0.6);
  
  @override
  set state (double opacity) {
    state = opacity;
  }
}