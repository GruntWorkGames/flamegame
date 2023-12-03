import 'package:flutter_riverpod/flutter_riverpod.dart';

final musicSliderValueState = StateNotifierProvider<MusicSliderValueState, double>((ref) {
  return MusicSliderValueState();
});

class MusicSliderValueState extends StateNotifier<double>{
  MusicSliderValueState() : super(50);
  
  void set(double value) {
    state = value;
  }
}