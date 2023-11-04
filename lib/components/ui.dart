import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_game/components/directional_pad.dart';
import 'package:flame_game/screens/game.dart';

class UI extends PositionComponent with HasGameRef<MainGame> {
  static TextComponent debugLabel = TextBoxComponent(text: '');

  @override
  FutureOr<void> onLoad() {
    anchor = Anchor.topLeft;
    if (debugLabel.parent != null) {
      debugLabel.removeFromParent();
    }
    debugLabel.anchor = Anchor.topCenter;
    debugLabel.position.x = game.size.x / 2;
    add(debugLabel);
    add(DirectionalPad());
  }
}
