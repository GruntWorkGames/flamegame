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
    switch(name) {
      case 'heal': return ItemType.heal;
      case 'weapon': return ItemType.weapon;
      case 'potion': return ItemType.potion;
    }
    return ItemType.none;
  }
}
