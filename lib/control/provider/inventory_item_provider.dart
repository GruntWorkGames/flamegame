import 'package:flame_game/control/json/inventory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryItemProvider = StateNotifierProvider<InventoryItemState, InventoryItem>((ref) {
  return InventoryItemState();
});

class InventoryItemState extends StateNotifier<InventoryItem>{
  InventoryItemState() : super(InventoryItem());
  
  void set(InventoryItem item) {
    state = item;
  }
}