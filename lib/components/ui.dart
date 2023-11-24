import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flame_game/components/buttons.dart';
import 'package:flame_game/components/directional_pad.dart';
import 'package:flame_game/screens/game.dart';
import 'package:flutter/material.dart';

class UI extends PositionComponent with HasGameRef<MainGame> {

  static UI instance = UI();

  static TextComponent debugLabel = TextBoxComponent(text: '');
  final coinText = TextBoxComponent(text: '23');
  final heartText = TextBoxComponent(text: '30');
  RectangleComponent? gameOverScreen;

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

    final heartImg = await game.images.load('heart.png');
    final heart = SpriteComponent.fromImage(heartImg);
    heart.scale = Vector2(2, 2);
    heart.position = Vector2(game.size.x - 96, 20);
    add(heart);

    add(heartText);
    heartText.position = Vector2(game.size.x - 64, 16);
    
    // final fps = FpsTextComponent();
    // fps.position.y = game.size.y - 30;
    // fps.position.x = 20;
    // add(fps);
  }

void showGameOver() {;
    game.overworld?.listenToInput = false;
    final blackPaint = Paint();
    blackPaint.color = Colors.black;
    gameOverScreen = RectangleComponent(size: game.size, paint: blackPaint, anchor: Anchor.topLeft);
    gameOverScreen?.opacity = 0;
    add(gameOverScreen!);

    gameOverScreen?.add(OpacityEffect.fadeIn(EffectController(duration: 3)));

    final regularTextStyle = TextStyle(fontSize: 62, color: BasicPalette.red.color);
    final regular = TextPaint(style: regularTextStyle);
    final label = TextComponent(
        text: 'You died',
        anchor: Anchor.center,
        position: Vector2(game.size.x/2, game.size.y/2 - 40),
        textRenderer: regular);
    gameOverScreen?.add(label);

    final btn = RoundedRectButton('MOAR');
    btn.position = Vector2(game.size.x/2, game.size.y/2 + 60);
    btn.onPressed = () {
      removeGameOver();
      game.overworldNavigator.loadNewGame();
    };
    gameOverScreen?.add(btn);
  }

  void removeGameOver() {
    gameOverScreen?.removeFromParent();
    game.overworld?.listenToInput = true;
  }
}
