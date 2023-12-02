import 'package:flame/components.dart';
import 'package:flame_game/components/game.dart';
import 'package:flame_game/components/overworld.dart';

enum TurnSystemState {
  initial, player, playerFinished, enemy, enemyFinished
}

class TurnSystem extends Component with HasGameRef<MainGame> {
  final Overworld overworld;
  TurnSystemState _state = TurnSystemState.initial;
  Function? playerFinishedCallback = null;
  Function? enemyFinishedCallback = null;

  TurnSystem({required this.overworld, this.playerFinishedCallback = null, this.enemyFinishedCallback});

  void updateState(TurnSystemState newState) {

    switch(newState) {
      case TurnSystemState.player:
        overworld.listenToInput = true;
        break;
      case TurnSystemState.playerFinished:
        overworld.listenToInput = false;
        if(playerFinishedCallback != null) {
          playerFinishedCallback!();
        }
        _state = TurnSystemState.enemy;
        overworld.enemyTurn();
        return;
      case TurnSystemState.enemy:
        break;
      case TurnSystemState.enemyFinished:
        overworld.listenToInput = true;
        _state = TurnSystemState.player;
        return;
      case TurnSystemState.initial:
    }

    _state = newState;
  }

  TurnSystemState getState() {
    return _state;
  }
  
}