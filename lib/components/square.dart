import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/painting.dart';

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