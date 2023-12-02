import 'package:flame/game.dart';
import 'package:flame_game/control/json/item.dart';

class CharacterData {
  int _health = 10;
  int _maxHealth = 30;
  int gold = 0;
  int hit = 1;
  int dodge = 1;
  int str = 1;
  int stam = 1;
  Vector2 tilePosition = Vector2(0,0);
  String mapfile = 'map.tmx';
  List<Item> inventory = [];
  
  int get maxHealth {
    return (stam * 5) + _maxHealth;
  }

  void heal(int hp) {
    final newMax = _health + hp;
    if (newMax > maxHealth) {
      _health = maxHealth;
    } else {
      _health = newMax;
    }
  }

  void set health(int h) {
    _health = h;
    if(_health > maxHealth) {
      _health = maxHealth;
    }
  }

  int get health {
    return _health;
  }

  CharacterData();

  void delete(Item item) {
    inventory.removeWhere((element) => item == element);
  }

  CharacterData.fromJson(Map<String, dynamic> json) {
    health = json['health'] ?? 10;
    _maxHealth = json['maxHealth'] ?? 30;
    gold = json['gold'] ?? 0;
    tilePosition.x = json['x'] ?? 0;
    tilePosition.y = json['y'] ?? 0;
    mapfile = json['mapfile'] ?? 'map.tmx';
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['health'] = this.health;
    data['maxHealth'] = this._maxHealth;
    data['gold'] = this.gold;
    data['x'] = tilePosition.x;
    data['y'] = tilePosition.y;
    data['mapfile'] = mapfile;
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
