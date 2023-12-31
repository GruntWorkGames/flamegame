import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uiProvider = StateNotifierProvider<UIState, UIViewDisplayType>((ref) {
  return UIState();
});

class UIState extends StateNotifier<UIViewDisplayType> {
  UIState() : super(UIViewDisplayType.invisible);

  void set(UIViewDisplayType type) {
    state = type;
  }
}