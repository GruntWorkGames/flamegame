import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UIScreenType {
  game, shop, menu, dialog, invisible
}

final uiProvider = StateNotifierProvider<UIState, UIScreenType>((ref) {
  return UIState();
});


class UIState extends StateNotifier<UIScreenType> {
  UIState() : super(UIScreenType.game);

  void set(UIScreenType type) {
    state = type;
  }
}