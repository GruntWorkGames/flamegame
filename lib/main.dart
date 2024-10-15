import 'package:flame_game/control/constants.dart';
import 'package:flame_game/screens/view/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final mainMenu = MainMenuFlutter();
  final scaffold = Scaffold(body: mainMenu);
  final theme = mainTheme.copyWith(textTheme: phoneTextTheme);
  final app = MaterialApp(home: scaffold, theme: theme);
  final ProviderScope scope = ProviderScope(child: app);
  runApp(scope);
}
