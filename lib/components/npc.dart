import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/palette.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/screens/components/game.dart';
import 'package:flutter/material.dart';

class NPC extends SpriteComponent with HasGameRef<MainGame> {
  final NpcData data;
  NPC(this.data) : super(position: data.position, size: Vector2(TILESIZE, TILESIZE));

  @override
  FutureOr<void> onLoad() async {
    this.sprite = await gameRef.loadSprite('npc1.png');
    anchor = Anchor.topLeft;
    position = data.position;
  }

  void speak() {
    if(game.currentSpeechBubble != null) {
      return;
    }

    final textPos = position.clone();
    textPos.y -= 50;
      final text = _NpcTextBox(
        data.speech,
        align: Anchor.center,
        size: Vector2(200, data.speechHeight.toDouble()),
        timePerChar: 0.05,
        margins: 2,
      )..position = textPos
      ..anchor = Anchor.center;
      parent!.add(text);
      game.currentSpeechBubble = text;
  }
}

class NpcData {
  String speech = '';
  String name = '';
  Vector2 position = Vector2.zero();
  int speechHeight = 75;
}

final _regularTextStyle =
    TextStyle(fontSize: 18, color: BasicPalette.white.color);
final _regular = TextPaint(style: _regularTextStyle);
// final _tiny = TextPaint(style: _regularTextStyle.copyWith(fontSize: 14.0));
final _box = _regular.copyWith(
  (style) => style.copyWith(
    color: Colors.black,
    fontFamily: 'monospace',
    letterSpacing: 2.0,
  ),
);

// final _shaded = TextPaint(
//   style: TextStyle(
//     color: BasicPalette.white.color,
//     fontSize: 40.0,
//     shadows: const [
//       Shadow(color: Colors.red, offset: Offset(2, 2), blurRadius: 2),
//       Shadow(color: Colors.yellow, offset: Offset(4, 4), blurRadius: 4),
//     ],
//   ),
// );

class _NpcTextBox extends TextBoxComponent {
  _NpcTextBox(
    String text, {
    super.align,
    super.size,
    double? timePerChar,
    double? margins,
  }) : super(
          text: text,
          textRenderer: _box,
          boxConfig: TextBoxConfig(
            maxWidth: 100,
            timePerChar: timePerChar ?? 0.05,
            growingBox: true,
            margins: EdgeInsets.all(margins ?? 25),
          ),
        );

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(rect, Paint()..color = Color.fromARGB(218, 158, 158, 158));
    super.render(canvas);
  }
}
