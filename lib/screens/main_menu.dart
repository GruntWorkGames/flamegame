import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

class AdvancedButtonExample extends FlameGame {
  static const String description =
      '''This example shows how you can use a button with different states''';

  @override
  Future<void> onLoad() async {
    final _regularTextStyle =
        TextStyle(fontSize: 42, color: BasicPalette.white.color);
    final regular = TextPaint(style: _regularTextStyle);

    final title = TextComponent(
        text: 'Its a game',
        anchor: Anchor.center,
        position: Vector2(size.x / 2, 10),
        textRenderer: regular);

    add(title);

    final defaultSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 200, 0, 1));

    final hoverSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 180, 0, 1));

    final downSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 100, 0, 1));

    final btn = AdvancedButtonComponent(
      defaultLabel: TextComponent(text: 'Kris'),
      position: Vector2(size.x / 2, 50),
      size: Vector2(250, 50),
      anchor: Anchor.center,
      defaultSkin: defaultSkin,
      hoverSkin: hoverSkin,
      downSkin: downSkin,
    );

    add(btn);
  }
}

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

    defaultSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 200, 0, 1));

    hoverSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 180, 0, 1));

    downSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 100, 0, 1));

    defaultSelectedSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 0, 200, 1));

    hoverAndSelectedSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 0, 180, 1));

    downAndSelectedSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 0, 100, 1));
  }
}

class DefaultButton extends AdvancedButtonComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    // defaultLabel = TextComponent(text: 'Default button');

    defaultSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 200, 0, 1));

    hoverSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 180, 0, 1));

    downSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 100, 0, 1));
  }
}

class DisableButton extends AdvancedButtonComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    disabledLabel = TextComponent(text: 'Disabled button');

    defaultSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 255, 0, 1));

    disabledSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(100, 100, 100, 1));
  }
}

class RoundedRectComponent extends PositionComponent with HasPaint {
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
// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:flame/game.dart';
// import 'package:flame/input.dart';
// import 'package:flutter/material.dart';

// class LevelsExample extends FlameGame {
//   static const String description = '''
//     In this example we showcase how you can utilize World components as levels.
//     Press the different buttons in the bottom to change levels and press in the
//     center to add new Ember's. You can see how level 1-3 keeps their state,
//     meanwhile the one called Resettable always resets.
//   ''';

//   LevelsExample() : super(world: Level());

//   late final TextComponent header;

//   @override
//   Future<void> onLoad() async {
//     header = TextComponent(
//       text: 'Main Menu',
//       position: Vector2(size.x / 2, 100),
//       anchor: Anchor.center,
//     );
//     // If you have a lot of HUDs you could also create separate viewports for
//     // each level and then just change them from within the world's onLoad with:
//     // game.cameraComponent.viewport = Level1Viewport();
//     final viewport = camera.viewport;
//     viewport.add(header);
//     final levels = [Level1(), Level2(), Level3()];
//     viewport.addAll(
//       [
//         LevelButton(
//           'Level 1',
//           onPressed: () => world = levels[0],
//           position: Vector2(size.x / 2, size.y / 2),
//         ),
//         LevelButton(
//           'Level 2',
//           onPressed: () {
//             print('hey');
//             world = levels[1];
//           },
//           position: Vector2(size.x / 2, size.y / 2 - 50),
//         ),
//         LevelButton(
//           'Level 3',
//           onPressed: () => world = levels[2],
//           position: Vector2(size.x / 2, size.y / 2 - 100),
//         ),
//       ],
//     );
//   }
// }

// class Level1 extends Level {
//   @override
//   Future<void> onLoad() async {
//     game.header.text = 'Level 1';
//   }
// }

// class Level2 extends Level {
//   @override
//   Future<void> onLoad() async {
//     game.header.text = 'Level 2';
//   }
// }

// class Level3 extends Level {
//   @override
//   Future<void> onLoad() async {
//     game.header.text = 'Level 3';
//   }
// }

// class Level extends World with HasGameReference<LevelsExample>, TapCallbacks {
//   @override
//   void onTapDown(TapDownEvent event) {}
// }

// class LevelButton extends ButtonComponent {
//   LevelButton(String text, {super.onPressed, super.position})
//       : super(
//           button: ButtonBackground(Colors.white),
//           buttonDown: ButtonBackground(Colors.orangeAccent),
//           children: [
//             TextComponent(
//               text: text,
//               position: Vector2(60, 20),
//               anchor: Anchor.center,
//             ),
//           ],
//           size: Vector2(120, 40),
//           anchor: Anchor.center,
//         );
// }

// class ButtonBackground extends PositionComponent with HasAncestor<LevelButton> {
//   ButtonBackground(Color color) {
//     _paint.color = color;
//   }

//   @override
//   void onMount() {
//     super.onMount();
//     size = ancestor.size;
//   }

//   late final _background = RRect.fromRectAndRadius(
//     size.toRect(),
//     const Radius.circular(5),
//   );
//   final _paint = Paint()..style = PaintingStyle.stroke;

//   @override
//   void render(Canvas canvas) {
//     canvas.drawRRect(_background, _paint);
//   }
// }
