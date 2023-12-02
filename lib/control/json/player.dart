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
    if (json['inventory'] != null) {
      json['inventory'].forEach((v) {
        inventory.add(Item.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['health'] = this.health;
    data['maxHealth'] = this.maxHealth;
    data['gold'] = this.gold;
    data['inventory'] = this.inventory.map((v) => v.toJson()).toList();
    return data;
  }
}
