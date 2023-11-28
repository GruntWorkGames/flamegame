import 'package:flame_game/control/json/inventory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryProvider = StateNotifierProvider<InventoryState, Inventory>((ref) {
  return InventoryState();
});

class InventoryState extends StateNotifier<Inventory> {
  InventoryState() : super(Inventory());

  void set(Inventory inventory) {
    state = inventory;
  }
}