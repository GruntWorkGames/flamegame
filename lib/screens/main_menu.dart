import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flame_game/components/buttons.dart';
import 'package:flame/components.dart';
import 'package:flame_game/screens/game.dart';

class MainMenu extends World with HasGameReference<MainGame>, TapCallbacks{

  Vector2 size = Vector2(0,0);
  MainMenu(this.size);

  @override
  FutureOr<void> onLoad() async {
    final regularTextStyle = TextStyle(fontSize: 62, color: BasicPalette.white.color);
    final regular = TextPaint(style: regularTextStyle);

    final title = TextComponent(
        text: 'Its a game',
        anchor: Anchor.center,
        position: Vector2(0, 0),
        textRenderer: regular);

    final btn = RoundedRectButton('Play');
    btn.position = Vector2(0, 100);

    add(title);
    add(btn);
  }
}