import 'dart:async';
import 'package:flame/components.dart';

class UI extends PositionComponent {
  @override
  FutureOr<void> onLoad() {
    final label = TextComponent(text: 'Label');
    label.anchor = Anchor.center;
    anchor = Anchor.center;
    add(label);
  }
}
