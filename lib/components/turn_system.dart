import 'package:flame/components.dart';
import 'package:flame_game/components/game.dart';
import 'package:flame_game/components/map_runner.dart';

enum TurnSystemState {
  initial, player, playerFinished, enemy, enemyFinished
}

class TurnSystem extends Component with HasGameRef<MainGame> {
  final MapRunner overworld;
  TurnSystemState _state = TurnSystemState.initial;
  Function? playerFinishedCallback;
  Function? enemyFinishedCallback;

  TurnSystem({required this.overworld, this.playerFinishedCallback, this.enemyFinishedCallback});
 
  void updateState(TurnSystemState newState) {

    switch(newState) {
      case TurnSystemState.player:
        overworld.listenToInput = true;
        break;
      case TurnSystemState.playerFinished:
        overworld.listenToInput = false;
        if(playerFinishedCallback != null) {
          playerFinishedCallback?.call();
        }
        _state = TurnSystemState.enemy;
        overworld.enemyTurn();
        overworld.playerMoved();
        return;
      case TurnSystemState.enemy:
        break;
      case TurnSystemState.enemyFinished:
        overworld.listenToInput = true;
        _state = TurnSystemState.player;
        if(overworld.shouldContinue) {
          overworld.directionPressed(overworld.lastDirection);
        }
        return;
      case TurnSystemState.initial:
    }

    _state = newState;
  }

  TurnSystemState getState() {
    return _state;
  }
  
}