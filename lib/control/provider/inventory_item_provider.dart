import 'package:flame_game/control/json/inventory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryItemProvider = StateNotifierProvider<InventoryItemState, Item>((ref) {
  return InventoryItemState();
});

class InventoryItemState extends StateNotifier<Item>{
  InventoryItemState() : super(Item());
  
  void set(Item item) {
    state = item;
  }
}