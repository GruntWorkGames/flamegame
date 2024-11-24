import 'package:flutter_riverpod/flutter_riverpod.dart';

final fxSliderValueState = StateNotifierProvider<FxSliderValueState, double>((ref) {
  return FxSliderValueState();
});

class FxSliderValueState extends StateNotifier<double>{
  FxSliderValueState() : super(50);
  
  @override
  set state (double value) {
    state = value;
  }
}