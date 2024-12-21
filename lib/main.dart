import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/screens/view/main_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const mainMenu = MainMenuFlutter();
  const scaffold = Scaffold(body: mainMenu);
  final theme = mainTheme.copyWith(textTheme: phoneTextTheme);
  final app = MaterialApp(home: scaffold, theme: theme);
  final scope = ProviderScope(child: app);
  runApp(scope);
}
