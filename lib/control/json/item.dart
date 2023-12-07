import 'package:flame_game/control/enum/item_type.dart';

class Item {
  String name = '';
  ItemType type = ItemType.none;
  double value = 0;
  String valueName = '';
  String description = '';
  double cost = 0;
  String inventoryUseText = '';
  bool isEquipped = false;
  bool isSelected = false;

  Item();

  Item.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    type = ItemType.typeFromString(json['type'] ?? '');
    value = json['value'] ?? 0;
    valueName = json['valueName'] ?? '';
    description = json['description'] ?? '';
    cost = json['cost'] ?? 0;
    inventoryUseText = json['inventoryUseText'] ?? '';
    isEquipped = json['isEquipped'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['type'] = this.type.name;
    data['value'] = this.value;
    data['valueName'] = this.valueName;
    data['description'] = this.description;
    data['cost'] = this.cost;
    data['inventoryUseText'] = this.inventoryUseText;
    data['isEquipped'] = this.isEquipped;
    return data;
  }
}
