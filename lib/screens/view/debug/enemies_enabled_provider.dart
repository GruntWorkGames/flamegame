import 'package:flutter_riverpod/flutter_riverpod.dart';

final enemiesEnabled = StateNotifierProvider<EnemiesEnabledState, bool>((ref) {
  return EnemiesEnabledState();
});

class EnemiesEnabledState extends StateNotifier<bool> {
  EnemiesEnabledState() : super(true);

  void set(bool type) {
    state = type;
  }
}