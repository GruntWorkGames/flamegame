import 'package:flutter_riverpod/flutter_riverpod.dart';

final goldProvider = StateNotifierProvider<GoldProvider, double>((ref) {
  return GoldProvider();
});

class GoldProvider extends StateNotifier<double> {
  GoldProvider() : super(0);
  
  void set(double value) {
    state = value;
  }
}