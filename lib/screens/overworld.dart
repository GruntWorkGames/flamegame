import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_game/components/player_component.dart';
import 'package:flame_game/components/ui.dart';
import 'package:flame_game/screens/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Overworld extends World with HasGameRef<MainGame> {
  @override
  FutureOr<void> onLoad() async {
    final TiledComponent tiledmap =
        await TiledComponent.load('map.tmx', Vector2.all(32));
    tiledmap.position = Vector2(0, 0);
    tiledmap.anchor = Anchor.center;
    add(tiledmap);
    final player = PlayerComponent();
    add(player);

    final ui = UI();
    game.camera.viewport.add(ui);
    game.camera.follow(player);
  }
}
