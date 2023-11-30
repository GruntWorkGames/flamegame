import 'package:flame_game/control/json/item.dart';

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
