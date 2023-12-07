import 'package:flame/game.dart';
import 'package:flame_game/control/json/item.dart';

class CharacterData {
  double _health = 10;
  double _maxHealth = 30;
  double gold = 0;
  double hit = 0;
  double dodge = 0;
  double str = 0;
  double stam = 0;
  double armor = 0;
  Vector2 tilePosition = Vector2(0,0);
  String mapfile = 'map.tmx';
  List<Item> inventory = [];
  
  double get maxHealth {
    return (stam * 5) + _maxHealth;
  }

  void heal(double hp) {
    final newMax = _health + hp;
    if (newMax > maxHealth) {
      _health = maxHealth;
    } else {
      _health = newMax;
    }
  }

  void set health(double h) {
    _health = h;
    if(_health > maxHealth) {
      _health = maxHealth;
    }
  }

  double get health {
    return _health;
  }

  CharacterData();

  void delete(Item item) {
    inventory.removeWhere((element) => item == element);
  }

  CharacterData.fromJson(Map<String, dynamic> json) {
    health = json['health'] ?? 10.0;
    _maxHealth = json['maxHealth'] ?? 30.0;
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
      addDefaultItems();
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
  
  void addDefaultItems() {
    final hPotion = {
      "name" : "Health Potion",
      "type" : "potion",
      "value" : 10.0,
      "valueName": "health",
      "description": "The thick red liquid reminds you of cough syrup.", 
      "cost" : 10.0,
      "inventoryUseText" : "Drink"
    };
    final sword = {
      "name" : "Dull Short Sword",
      "type" : "weapon",
      "value" : 5.0,
      "valueName": "damage",
      "description": "A nearly useless weapon. A kids toy.",
      "cost" : 30.0,
      "inventoryUseText" : "Equip",
      "isEquipped": true
    };
    final helmet = {
      "name" : "Armor Helm",
      "type" : "armor",
      "value" : 2.0,
      "valueName": "mitigation",
      "description": "Tarnished and flimsy.",
      "cost" : 20.0,
      "inventoryUseText" : "Equip",
      "isEquipped": true
    };

    inventory.add(Item.fromJson(hPotion));
    inventory.add(Item.fromJson(sword));
    inventory.add(Item.fromJson(helmet));
  }
}
