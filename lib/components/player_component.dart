import 'package:karas_quest/components/melee_character.dart';
import 'package:karas_quest/control/json/item.dart';

class PlayerComponent extends MeleeCharacter {
  PlayerComponent();

  void equipArmor(Item item) {
    armor.isEquipped = false;
    armor = item;
    armor.isEquipped = true;
  }

  void equipWeapon(Item item) {
    weapon.isEquipped = false;
    weapon = item;
    weapon.isEquipped = true;
  }
}