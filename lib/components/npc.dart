import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/screens/game.dart';

class NPC extends SpriteComponent with HasGameRef<MainGame> {
  final NpcData data;
  NPC(this.data) : super(position: data.position, size: Vector2(TILESIZE, TILESIZE));

  @override
  FutureOr<void> onLoad() async {
    this.sprite = await gameRef.loadSprite('npc1.png');
    anchor = Anchor.topLeft;
    position = data.position;
  }
}

class NpcData {
  String speech = '';
  String name = '';
  Vector2 position = Vector2.zero();
}

class NpcTextBox extends TextBoxComponent {
  NpcTextBox(String text) : super(
    text: text,
    textRenderer: tiny,
    boxConfig: TextBoxConfig(timePerChar: 0.05),
  );

  final bgPaint = Paint()..color = Color(0xFFFF00FF);
  final borderPaint = Paint()..color = Color(0xFF000000)..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(rect, bgPaint);
    canvas.drawRect(rect.deflate(10), borderPaint);
    super.render(canvas);
  }
}
