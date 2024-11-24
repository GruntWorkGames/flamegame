import 'package:flame_game/control/json/item.dart';

class Shop {
  String message = '';
  String owner = '';
  List<Item> items = [];

  Shop();

  Shop.fromJson(Map<String, dynamic> json) {
    final ownerVal = json['name'] as String? ?? '';
    owner = ownerVal;

    final shop = json['shop']  as Map<String, dynamic>? ?? {};
    final messageVal = shop['message'] ?? '';

    if(messageVal is String) {
       message = messageVal;
    }

    final itemsJson = shop['items'] as List<Map<String, dynamic>>? ?? [];
    for (final item in itemsJson) {
      items.add(Item.fromJson(item));
    }
  }
}
