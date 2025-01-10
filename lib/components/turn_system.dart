import 'package:flame/components.dart';
import 'package:karas_quest/components/map_runner.dart';
import 'package:karas_quest/components/game.dart';

enum TurnSystemState {
  initial, player, playerFinished, enemy, enemyFinished
}

class TurnSystem extends Component with HasGameRef<MainGame> {
  final MapRunner mapRunner;
  TurnSystemState _state = TurnSystemState.initial;
  Function? playerFinishedCallback;
  Function? enemyFinishedCallback;

  TurnSystem({required this.mapRunner, this.playerFinishedCallback, this.enemyFinishedCallback});
 
  void updateState(TurnSystemState newState) {

    switch(newState) {
      case TurnSystemState.player:
        mapRunner.listenToInput = true;
        break;
      case TurnSystemState.playerFinished:
        mapRunner.listenToInput = false;
        if(playerFinishedCallback != null) {
          playerFinishedCallback?.call();
        }
        _state = TurnSystemState.enemy;
        mapRunner.enemyTurn();
        mapRunner.playerMoved();
        return;
      case TurnSystemState.enemy:
        break;
      case TurnSystemState.enemyFinished:
        mapRunner.listenToInput = true;
        _state = TurnSystemState.player;
        if(mapRunner.shouldContinue) {
          mapRunner.directionPressed(mapRunner.lastDirection);
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