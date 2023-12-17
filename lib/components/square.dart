import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_game/components/game.dart';
import 'package:flutter/material.dart';

// used for debugging
class Square extends PositionComponent {
  PaletteEntry palette;
  Square(this.palette);
  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromCircle(center: Offset(8,8), radius: 7.4), 
    palette.paint()..style = PaintingStyle.stroke..strokeWidth = 1);
  }
}

class RectComponent extends PositionComponent with HasPaint {
  final PaletteEntry _color;
  final Vector2 _size;
  final Vector2 _position;

  RectComponent(this._color, this._size, this._position);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(_position.x, _position.y, _size.x, _size.y),
      _color.paint()
    );
  }
}

class FillScreen extends PositionComponent with HasPaint, HasGameRef<MainGame> {
  FillScreen();

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.largest, paint..color = Colors.black);
  }
}