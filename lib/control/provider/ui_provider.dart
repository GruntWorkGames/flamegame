import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karas_quest/control/enum/ui_view_type.dart';

final uiProvider = StateNotifierProvider<UIState, UIViewDisplayType>((ref) {
  return UIState();
});

class UIState extends StateNotifier<UIViewDisplayType> {
  UIState() : super(UIViewDisplayType.invisible);

  void set(UIViewDisplayType type) {
    state = type;
  }
}