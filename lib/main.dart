import 'package:flame/game.dart';
import 'package:flame_game/screens/components/game.dart';
import 'package:flame_game/screens/view/ui_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final game = MainGame();
  final gameWidget = GameWidget(game: game);
  final titleStyle = TextStyle(fontSize: 18, color: Colors.white);
  final textWrappedGameWidget = DefaultTextStyle(style:titleStyle, child: gameWidget);
  final stack = Stack(children: [textWrappedGameWidget, UIView(game)]);
  final ProviderScope scope = ProviderScope(child: stack);
  final scaffold = Scaffold(body: scope);
  final app = MaterialApp(home: scaffold);
  runApp(app);
}