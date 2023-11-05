import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/screens/game.dart';

class NPC extends SpriteComponent with HasGameRef<MainGame> {
  NPC() : super(size: Vector2(TILESIZE, TILESIZE));

  @override
  FutureOr<void> onLoad() async {
    this.sprite = await gameRef.loadSprite('npc1.png');
    anchor = Anchor.topLeft;
  }
}