import 'package:flame_game/control/enum/item_type.dart';
import 'package:flame_game/control/json/shop.dart';

class Inventory {
  List<InventoryItem> items = [];

  Inventory();

  Inventory.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] ?? [];
    for (final item in itemsJson) {
      items.add(InventoryItem.fromJson(item));
    }
  }

  void delete(InventoryItem item) {
    items.removeWhere((element) => item == element);
  }
}

class InventoryItem {
  String name = '';
  ItemType type = ItemType.none;
  int value = 0;
  String description = '';

  InventoryItem();

  InventoryItem.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    value = json['value'] ?? 0;
    description = json['description'] ?? '';
    type = ItemType.typeFromString(json['type'] ?? '');
  }

  InventoryItem.fromShopItem(ShopItem item) {
    name = item.name;
    description = 'set me';
    value = -1;
    type = ItemType.none;
  }
}
