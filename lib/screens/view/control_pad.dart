
import 'package:flame_game/components/game.dart';
import 'package:flame_game/control/provider/button_opacity.dart';
import 'package:flame_game/control/enum/direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ControlPad extends ConsumerStatefulWidget {
  final MainGame game;
  ControlPad(this.game);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ControlPadState(game);
  }
}

class _ControlPadState extends ConsumerState {
  final MainGame game;

  _ControlPadState(this.game);

  @override
  Widget build(BuildContext context) {
    final color = Colors.white;
    final leftIcon = Icon(Icons.chevron_left, color: color);
    final rightIcon = Icon(Icons.chevron_right, color: color);
    final upIcon = Transform.rotate(angle: 90 * 3.14 / 180, child: Icon(Icons.chevron_left, color: color));
    final downIcon = Transform.rotate(angle: -90 * 3.14 / 180, child: Icon(Icons.chevron_left, color: color));
    final upButton = _buildButton(Direction.up, upIcon);
    final downButton = _buildButton(Direction.down, downIcon); 
    final leftButton = _buildButton(Direction.left, leftIcon);
    final rightButton = _buildButton(Direction.right, rightIcon);

    final topRow = Row(mainAxisAlignment: MainAxisAlignment.center, children: [upButton]);
    final middleRow = Padding(padding: EdgeInsets.symmetric(horizontal: 10), 
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [leftButton, rightButton]));
    final bottomRow = Padding(padding: EdgeInsets.only(bottom: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [downButton]));
    return Column(children: [const Spacer(), topRow, middleRow, bottomRow]);
  }

  Widget _buildButton(Direction direction, Widget child) {
    final padding = EdgeInsets.fromLTRB(30, 10, 30, 10);
    final buttonOpacity = ref.watch(buttonOpacityProvider);
    final icon = Padding(padding: padding, child: child);
    final dec = BoxDecoration(color: Colors.grey.withOpacity(buttonOpacity), borderRadius: BorderRadius.circular(30));
    final border = BorderRadius.circular(30.0);
    return Material(color: Colors.transparent, child: InkWell(customBorder: RoundedRectangleBorder(borderRadius: border), 
    // onTap: (){game.directionPressed(direction);}, 
    onTapDown: (_)=>game.directionDown(direction),
    onTapUp: (_)=>game.directionUp(direction),
    onTapCancel: ()=>game.directionUp(direction),
    child: Ink(decoration: dec, child: icon)));
  }
}
