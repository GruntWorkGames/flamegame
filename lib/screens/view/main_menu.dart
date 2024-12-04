import 'dart:async';

import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart' as flame;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/screens/view/ui_layer.dart';

class MainMenuFlutter extends ConsumerWidget {
  const MainMenuFlutter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = GameWidget(game: _MapBackground());
    const titleStyle = TextStyle(fontSize: 50, color: Colors.black, fontFamily: 'Times New Roman', shadows: [Shadow(blurRadius: 2, color: Colors.white, offset: Offset(2, 2))]);
    const buttonStyle = TextStyle(fontSize: 32, color: Colors.black);
    final buttonColors = ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if(states.contains(WidgetState.pressed)) {
        return Colors.grey[700]!;
      } else {
        return Colors.grey[400]!;
      }
    }));
    const text = Text("Kara's Quest", style: titleStyle);
    const spacer = SizedBox(height: 50);
    final playButton = ElevatedButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) { 
        final game = MainGame();
        final gameWidget = GameWidget(game: game);
        final stack = Stack(children: [gameWidget, UILayer(game)]);
        final scaffold = Scaffold(body: stack);
        return scaffold;
      }));
    }, style: buttonColors, child: const Text('Play', style: buttonStyle));
    final centeredCol = Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [text, spacer, playButton]));
    final stack = Stack(children:[game, centeredCol]);
    return stack;
  }
}

class _MapBackground extends FlameGame {
  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    final tiledmap = await flame.TiledComponent.load('map.tmx', Vector2.all(64));
    add(tiledmap);
    tiledmap.position = tiledmap.position / 2;

    final move = MoveEffect.by(Vector2(-1300,-800), EffectController(duration: 60, alternate: true, infinite: true));
    tiledmap.add(move);

  }
}