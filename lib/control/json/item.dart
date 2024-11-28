import 'package:flame_game/control/enum/item_type.dart';

class Item {
  ItemType type = ItemType.none;
  int value = 0;
  int cost = 0;
  String name = '';
  String valueName = '';
  String description = '';
  String inventoryUseText = '';
  bool isEquipped = false;
  bool isSelected = false;

  Item();

  Item.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String? ?? '';
    final typeString = json['type'] as String? ?? '';
    type = ItemType.typeFromString(typeString);

    value = json['value'] as int? ?? 0;
    valueName = json['valueName'] as String? ?? '';
    description = json['description'] as String? ?? '';
    cost = json['cost'] as int? ?? 0;
    inventoryUseText = json['inventoryUseText'] as String? ?? '';
    isEquipped = json['isEquipped'] as bool? ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type.name;
    data['value'] = value;
    data['valueName'] = valueName;
    data['description'] = description;
    data['cost'] = cost;
    data['inventoryUseText'] = inventoryUseText;
    data['isEquipped'] = isEquipped;
    return data;
  }
}
