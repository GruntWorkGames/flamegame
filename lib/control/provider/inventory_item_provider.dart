import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karas_quest/control/json/item.dart';

final inventoryItemProvider = StateNotifierProvider<InventoryItemState, Item>((ref) {
  return InventoryItemState();
});

class InventoryItemState extends StateNotifier<Item>{
  InventoryItemState() : super(Item());
  
  void set(Item item) {
    state.isSelected = false;
    state = item;
  }
}