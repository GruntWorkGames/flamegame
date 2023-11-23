import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_game/components/directional_pad.dart';
import 'package:flame_game/screens/game.dart';

class UI extends PositionComponent with HasGameRef<MainGame> {
  static TextComponent debugLabel = TextBoxComponent(text: '');
  final coinText = TextBoxComponent(text: '23');

  @override
  FutureOr<void> onLoad() async {
    anchor = Anchor.topLeft;
    if (debugLabel.parent != null) {
      debugLabel.removeFromParent();
    }
    debugLabel.anchor = Anchor.topCenter;
    debugLabel.position.x = game.size.x / 2;
    debugLabel.position.y = 10;
    add(debugLabel);

    final dPad = DirectionalPad();
    dPad.position =
        Vector2(game.size.x / 2 - (64 * 3) / 2, game.size.y - 64 * 2);
    add(dPad);

    final coinImg = await game.images.load('coin.png');
    final coin = SpriteComponent.fromImage(coinImg);
    coin.scale = Vector2(2, 2);
    coin.position = Vector2(game.size.x - 96, 64);
    add(coin);

    add(coinText);
    coinText.position = Vector2(game.size.x - 64, 58);
    
    // final fps = FpsTextComponent();
    // fps.position.y = game.size.y - 30;
    // fps.position.x = 20;
    // add(fps);
  }
}
