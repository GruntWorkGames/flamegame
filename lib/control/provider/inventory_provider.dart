import 'package:flame_game/control/json/character_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryProvider = StateNotifierProvider<InventoryState, CharacterData>((ref) {
  return InventoryState();
});

class InventoryState extends StateNotifier<CharacterData> {
  InventoryState() : super(CharacterData());

  void set(CharacterData inventory) {
    state = inventory;
  }
}