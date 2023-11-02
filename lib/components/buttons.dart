import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

class ToggleButton extends ToggleButtonComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    defaultLabel = TextComponent(
      text: 'Toggle button', 
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 24,
          color: BasicPalette.white.color,
        ),
      ),
    );

    defaultSelectedLabel = TextComponent(
      text: 'Toggle button',
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 24,
          color: BasicPalette.red.color,
        ),
      ),
    );

    defaultSkin = _RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 200, 0, 1));

    hoverSkin = _RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 180, 0, 1));

    downSkin = _RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 100, 0, 1));

    defaultSelectedSkin = _RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 0, 200, 1));

    hoverAndSelectedSkin = _RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 0, 180, 1));

    downAndSelectedSkin = _RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 0, 100, 1));
  }
}

class RoundedRectButton extends AdvancedButtonComponent {
  String label = '';
  RoundedRectButton(this.label);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    defaultLabel = TextComponent(text: label);
    
    anchor = Anchor.center;
    
    size = Vector2(250, 50);

    defaultSkin = _RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 200, 0, 1));

    hoverSkin = _RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 180, 0, 1));

    downSkin = _RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 100, 0, 1));
  }
}

class _RoundedRectComponent extends PositionComponent with HasPaint {
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0,
        0,
        width,
        height,
        topLeft: Radius.circular(height),
        topRight: Radius.circular(height),
        bottomRight: Radius.circular(height),
        bottomLeft: Radius.circular(height),
      ),
      paint,
    );
  }
}