import 'package:flame_game/control/enum/item_type.dart';

class Inventory {
  List<InventoryItem> items = [];

  Inventory();

  Inventory.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] ?? [];
    for (final item in itemsJson) {
      items.add(InventoryItem.fromJson(item));
    }
  }
}

class InventoryItem {
  String name = '';
  ItemType type = ItemType.none;
  int value = 0;

  InventoryItem();

  InventoryItem.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    value = json['value'] ?? 0;
    type = ItemType.typeFromString(json['type'] ?? '');
  }
}
