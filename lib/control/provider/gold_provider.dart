import 'package:flutter_riverpod/flutter_riverpod.dart';

final goldProvider = StateNotifierProvider<GoldProvider, int>((ref) {
  return GoldProvider();
});

class GoldProvider extends StateNotifier<int> {
  GoldProvider() : super(0);
  
  void set(int value) {
    state = value;
  }
}