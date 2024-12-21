import 'package:flutter_riverpod/flutter_riverpod.dart';

final healthProvider = StateNotifierProvider<HealthProvider, int>((ref) {
  return HealthProvider();
});

class HealthProvider extends StateNotifier<int> {
  HealthProvider() : super(0);
  
  void set(int value) {
    state = value;
  }
}