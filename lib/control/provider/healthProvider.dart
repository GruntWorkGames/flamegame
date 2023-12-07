import 'package:flutter_riverpod/flutter_riverpod.dart';

final healthProvider = StateNotifierProvider<HealthProvider, double>((ref) {
  return HealthProvider();
});

class HealthProvider extends StateNotifier<double> {
  HealthProvider() : super(0);
  void set(double value) {
    state = value;
  }
}