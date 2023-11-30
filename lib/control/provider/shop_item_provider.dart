import 'package:flame_game/control/json/inventory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopItemProvider = StateNotifierProvider<ShopItemProvider, Item>((ref) {
  return ShopItemProvider();
});

class ShopItemProvider extends StateNotifier<Item>{
  ShopItemProvider() : super(Item());
  
  void set(Item item) {
    state = item;
  }
}