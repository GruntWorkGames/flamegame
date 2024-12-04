import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karas_quest/control/json/character_data.dart';

final inventoryProvider = StateNotifierProvider<InventoryState, CharacterData>((ref) {
  return InventoryState();
});

class InventoryState extends StateNotifier<CharacterData> {
  InventoryState() : super(CharacterData());
  
  void set(CharacterData inventory) {
    state = inventory;
  }
}