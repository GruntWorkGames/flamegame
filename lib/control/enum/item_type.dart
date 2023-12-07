enum ItemType {
  heal,
  food,
  weapon,
  armor,
  potion,
  torch,
  none;

  const ItemType();

  static ItemType typeFromString(String name) {
    switch (name) {
      case 'armor':
        return ItemType.armor;
      case 'heal':
        return ItemType.heal;
      case 'weapon':
        return ItemType.weapon;
      case 'potion':
        return ItemType.potion;
      case '':
        return ItemType.none;
    }
    return ItemType.none;
  }
}
