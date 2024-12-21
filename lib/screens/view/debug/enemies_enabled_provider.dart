import 'package:flutter_riverpod/flutter_riverpod.dart';

final enemiesEnabled = StateNotifierProvider<EnemiesEnabledState, bool>((ref) {
  return EnemiesEnabledState();
});

class EnemiesEnabledState extends StateNotifier<bool> {
  EnemiesEnabledState() : super(true);

  // ignore: avoid_positional_boolean_parameters
  void set(bool enemyType) {
    state = enemyType;
  }
}