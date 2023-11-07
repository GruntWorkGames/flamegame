import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/painting.dart';

// used for debugging
class Square extends PositionComponent {
  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromCircle(center: Offset(16,16), radius: 16), 
    BasicPalette.red.paint()..style = PaintingStyle.stroke..strokeWidth = 1);
  }
}