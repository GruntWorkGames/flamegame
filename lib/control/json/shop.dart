import 'package:flame_game/control/json/item.dart';

class Shop {
  String message = '';
  String owner = '';
  List<Item> items = [];

  Shop();

  Shop.fromJson(Map<String, dynamic> json) {
    owner = json['name'] ?? '';
    final shop = json['shop'] ?? {};
    message = shop['message'] ?? '';
    final itemsJson = shop['items'] ?? [];
    for (final item in itemsJson) {
      items.add(Item.fromJson(item));
    }
  }
}
