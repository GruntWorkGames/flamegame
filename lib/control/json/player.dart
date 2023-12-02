import 'package:flame_game/control/json/item.dart';

class CharacterData {
  int health = 10;
  int maxHealth = 30;
  int gold = 0;
  List<Item> inventory = [];

  CharacterData();

  void delete(Item item) {
    inventory.removeWhere((element) => item == element);
  }

  CharacterData.fromJson(Map<String, dynamic> json) {
    health = json['health'] ?? 10;
    maxHealth = json['maxHealth'] ?? 30;
    gold = json['gold'] ?? 0;
    final inventoryNode = json['inventory'] ?? [];
    if (inventoryNode != null && inventoryNode.isNotEmpty) {
      json['inventory'].forEach((v) {
        inventory.add(Item.fromJson(v));
      });
    } else {
      _addDefaultItems();
    }
  }

  Map<String, dynamic> toJson() {
    print('toJson');
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['health'] = this.health;
    data['maxHealth'] = this.maxHealth;
    data['gold'] = this.gold;
    data['inventory'] = this.inventory.map((v) => v.toJson()).toList();
    return data;
  }
  
  void _addDefaultItems() {
    final hPotion = {
        "name" : "Health Potion",
        "type" : "potion",
        "value" : 10,
        "valueName": "health",
        "description": "The thick red liquid reminds you of cough syrup.", 
        "cost" : 10,
        "inventoryUseText" : "Drink"
    };
    final sword = {
        "name" : "Dull Short Sword",
        "type" : "weapon",
        "value" : 2,
        "valueName": "damage",
        "description": "A nearly useless weapon. A kids toy.",
        "cost" : 11,
        "inventoryUseText" : "Equip",
        "isEquipped": true
    };

    inventory.add(Item.fromJson(hPotion));
    inventory.add(Item.fromJson(sword));
  }
}
