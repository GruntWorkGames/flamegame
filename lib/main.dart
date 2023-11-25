import 'package:flame/game.dart';
import 'package:flame_game/screens/game.dart';
import 'package:flame_game/screens/ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final game = MainGame();
  final gameWidget = GameWidget(game: game);
  final titleStyle = TextStyle(fontSize: 18, color: Colors.white);
  final textWrappedGameWidget = DefaultTextStyle(style:titleStyle, child: gameWidget);
  final stack = Stack(children: [textWrappedGameWidget, UIFlutter(game)]);
  final ProviderScope scope = ProviderScope(child: stack);
  final app = MaterialApp(home: scope);
  runApp(app);
}