import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame_game/components/game.dart';
import 'package:flame_game/screens/view/ui_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainMenuFlutter extends ConsumerWidget {
  MainMenuFlutter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapImage = ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Transform.scale(scale: 5, filterQuality: FilterQuality.high, child: Image.asset('assets/images/map.png')));
    final tween = TweenAnimationBuilder(tween: Tween<Offset>(begin: Offset(-530, -100), end: Offset(400, 500)), duration: const Duration(seconds: 60), 
    builder: (_, offset, __){
      return Transform.translate(offset: offset, child: mapImage);
    }, child: mapImage);

    final titleStyle = TextStyle(fontSize: 50, color: Colors.black, fontFamily: "Times New Roman", shadows: [Shadow(blurRadius: 2, color: Colors.white, offset: const Offset(2, 2))]);
    final buttonStyle = TextStyle(fontSize: 32, color: Colors.black);
    final buttonColors = ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      if(states.contains(MaterialState.pressed)) {
        return Colors.grey[700]!;
      } else {
        return Colors.grey[400]!;
      }
    }));
    final text = Text('Kara\'s Quest', style: titleStyle);
    final spacer = SizedBox(height: 50);
    final playButton = ElevatedButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) { 
        final game = MainGame();
        final gameWidget = GameWidget(game: game);
        final stack = Stack(children: [gameWidget, UIView(game)]);
        final scaffold = Scaffold(body: stack);
        return scaffold;
      }));
    }, child: Text('Play', style: buttonStyle), style: buttonColors);
    final centeredCol = Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [text, spacer, playButton]));
    final stack = Stack(children:[tween, centeredCol]);
    return stack;
  }
}