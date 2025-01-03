import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karas_quest/control/json/shop.dart';


final shopProvider = StateNotifierProvider<ShopState, Shop>((ref) {
  return ShopState();
});

class ShopState extends StateNotifier<Shop> {
  ShopState() : super(Shop());

  void set(Shop shop) {
    state = shop;
  }
}