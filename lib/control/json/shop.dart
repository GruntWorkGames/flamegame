import 'package:karas_quest/control/json/item.dart';

class Shop {
  String message = '';
  String owner = '';
  List<Item> items = [];

  Shop();

  Shop.fromJson(Map<String, dynamic> json) {
    owner = json['name'] as String? ?? '';

    final shop = json['shop']  as Map<String, dynamic>? ?? {};
    message = shop['message'] as String? ?? '';
    
    final itemsJson = shop['items'] as List<dynamic>? ?? [];
    for (final item in itemsJson) {
      final itemMap = item as Map<String,dynamic>? ?? {};
      items.add(Item.fromJson(itemMap));
    }
  }
}
