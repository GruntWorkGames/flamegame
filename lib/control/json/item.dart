import 'package:flame_game/control/enum/item_type.dart';

class Item {
  String name = '';
  ItemType type = ItemType.none;
  int value = 0;
  String description = '';
  bool isSelected = false;
  String inventoryUseText = 'Use';
  String valueName = '';
  int cost = 0;
  bool isEquipped = false;

  Item();

  Item.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    value = json['value'] ?? 0;
    description = json['description'] ?? '';
    type = ItemType.typeFromString(json['type'] ?? '');
    cost = json['cost'] ?? 0;
    inventoryUseText = json['inventoryUseText'] ?? 'Use';
    valueName = json['valueName'] ?? '';
    isEquipped = json['isEquipped'] ?? false;
  }
}