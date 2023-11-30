import 'package:flame_game/control/enum/item_type.dart';

class Inventory {
  List<Item> items = [];

  Inventory();

  Inventory.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] ?? [];
    for (final item in itemsJson) {
      items.add(Item.fromJson(item));
    }
  }

  void delete(Item item) {
    items.removeWhere((element) => item == element);
  }
}

class Item {
  String name = '';
  ItemType type = ItemType.none;
  int value = 0;
  String description = '';
  bool isSelected = false;
  String inventoryUseText = 'Use';
  String valueName = '';
  int cost = 0;

  Item();

  Item.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    value = json['value'] ?? 0;
    description = json['description'] ?? '';
    type = ItemType.typeFromString(json['type'] ?? '');
    cost = json['cost'] ?? 0;
    inventoryUseText = json['inventoryUseText'] ?? 'Use';
    valueName = json['valueName'] ?? '';
  }
}
