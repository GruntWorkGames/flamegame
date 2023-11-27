import 'package:flame_game/control/json/shop.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final shopProvider = StateNotifierProvider<ShopState, Shop>((ref) {
  return ShopState();
});

class ShopState extends StateNotifier<Shop> {
  ShopState() : super(Shop());

  void set(Shop shop) {
    state = shop;
  }
}