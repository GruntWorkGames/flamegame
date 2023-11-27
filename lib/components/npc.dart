import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_game/constants.dart';
import 'package:flame_game/screens/components/game.dart';

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
  String shopJsonFile = '';
  Vector2 position = Vector2.zero();
}