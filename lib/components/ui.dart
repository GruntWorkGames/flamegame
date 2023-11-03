import 'dart:async';
import 'package:flame/components.dart';

class UI extends PositionComponent {
  static TextComponent debugLabel = TextBoxComponent(text: '');

  @override
  FutureOr<void> onLoad() {
    if (debugLabel.parent != null) {
      debugLabel.removeFromParent();
    }
    debugLabel.anchor = Anchor.center;
    anchor = Anchor.center;
    add(debugLabel);

    
  }
}
