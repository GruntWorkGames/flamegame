import 'package:karas_quest/control/json/item.dart';
import 'package:karas_quest/control/objects/tile.dart' as k;

class CharacterData {
  int _health = 10;
  int _maxHealth = 30;
  int gold = 0;
  int hit = 40;
  int dodge = 5;
  int str = 1;
  int stam = 1;
  int armor = 1;
  int experience = 0;
  int level = 1;
  k.Tile tilePosition = k.Tile(0, 0);
  String mapfile = 'bigmap.tmx';
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

  set health(int h) {
    _health = h;
    if(_health > maxHealth) {
      _health = maxHealth;
    }
  }

  int get health {
    return _health;
  }

  CharacterData() {
    addDefaultItems();
  }

  void delete(Item item) {
    inventory.removeWhere((element) => item == element);
  }

  CharacterData.fromMap(Map<String, dynamic> json) {
    _health = json['health'] as int? ?? 10;
    _maxHealth = json['maxHealth'] as int? ?? 30;
    experience = json['experience'] as int? ?? 0;
    hit = json['hit'] as int? ?? 40;
    dodge = json['dodge'] as int? ?? 5;
    str = json['str'] as int? ?? 1;
    stam = json['stam'] as int? ?? 1;
    gold = json['gold'] as int? ?? 0;
    tilePosition.x = json['x'] as int? ?? 0;
    tilePosition.y = json['y'] as int? ?? 0;
    level = json['level'] as int? ?? 1;
    mapfile = json['mapfile'] as String? ?? 'bigmap.tmx';
    final inventoryNode = json['inventory'] as List<dynamic>? ?? [];
    if (inventoryNode.isNotEmpty) {
      final inventoryList = json['inventory'] as List<dynamic>? ?? [];
      inventoryList.forEach((v) {
        final item = v as Map<String, dynamic>? ?? {};
        inventory.add(Item.fromMap(item));
      });
    } else {
      addDefaultItems();
    }
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['health'] = health;
    data['maxHealth'] = _maxHealth;
    data['gold'] = gold;
    data['x'] = tilePosition.x;
    data['y'] = tilePosition.y;
    data['hit'] = hit;
    data['str'] = str;
    data['stam'] = stam;
    data['dodge'] = dodge;
    data['mapfile'] = mapfile;
    data['level'] = level;
    data['experience'] = experience;
    data['inventory'] = inventory.map((v) => v.toMap()).toList();
    return data;
  }
  
  void addDefaultItems() {
    final hPotion = {
      'name' : 'Health Potion',
      'type' : 'potion',
      'value' : 10,
      'valueName': 'health',
      'description': 'The thick red liquid reminds you of cough syrup.', 
      'cost' : 10,
      'inventoryUseText' : 'Drink'
    };
    final sword = {
      'name' : 'Dull Short Sword',
      'type' : 'weapon',
      'value' : 4,
      'valueName': 'damage',
      'description': 'A nearly useless weapon. A kids toy.',
      'cost' : 30,
      'inventoryUseText' : 'Equip',
      'isEquipped': true
    };
    final helmet = {
      'name' : 'Armor Helm',
      'type' : 'armor',
      'value' : 2,
      'valueName': 'mitigation',
      'description': 'Tarnished and flimsy.',
      'cost' : 20,
      'inventoryUseText' : 'Equip',
      'isEquipped': true
    };

    inventory.add(Item.fromMap(hPotion));
    inventory.add(Item.fromMap(sword));
    inventory.add(Item.fromMap(helmet));
  }
}
