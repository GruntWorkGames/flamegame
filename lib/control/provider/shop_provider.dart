import 'package:flutter_riverpod/flutter_riverpod.dart';

class Shop {
  Shop();
  String title = '';
  String message = '';
  List<Function> functions = [];
}

final shopProvider = StateNotifierProvider<ShopState, Shop>((ref) {
  return ShopState();
});

class ShopState extends StateNotifier<Shop> {
  ShopState() : super(Shop());

  void set(Shop shop) {
    state = shop;
  }
}