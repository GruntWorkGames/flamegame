import 'package:karas_quest/control/enum/direction.dart';

mixin MapRunner {
  bool listenToInput = false;
  bool shouldContinue = false;
  Direction lastDirection = Direction.none;
  void enemyTurn();
  void playerMoved();
  void directionPressed(Direction direction);
}