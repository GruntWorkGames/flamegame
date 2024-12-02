
import 'package:flame_game/components/game.dart';
import 'package:flame_game/control/enum/direction.dart';
import 'package:flame_game/control/provider/button_opacity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ControlPad extends ConsumerStatefulWidget {
  final MainGame game;
  const ControlPad(this.game, {super.key});

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
    const color = Colors.white;
    const leftIcon = Icon(Icons.chevron_left, color: color);
    const rightIcon = Icon(Icons.chevron_right, color: color);
    final upIcon = Transform.rotate(angle: 90 * 3.14 / 180, child: const Icon(Icons.chevron_left, color: color));
    final downIcon = Transform.rotate(angle: -90 * 3.14 / 180, child: const Icon(Icons.chevron_left, color: color));
    final upButton = _buildButton(Direction.up, upIcon);
    final downButton = _buildButton(Direction.down, downIcon); 
    final leftButton = _buildButton(Direction.left, leftIcon);
    final rightButton = _buildButton(Direction.right, rightIcon);

    final topRow = Row(mainAxisAlignment: MainAxisAlignment.center, children: [upButton]);
    final middleRow = Padding(padding: const EdgeInsets.symmetric(horizontal: 10), 
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [leftButton, const SizedBox(width: 50), rightButton]));
    final bottomRow = Padding(padding: const EdgeInsets.only(bottom: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [downButton]));
    return Column(children: [const Spacer(), topRow, middleRow, bottomRow]);
  }

  Widget _buildButton(Direction direction, Widget child) {
    const padding = EdgeInsets.fromLTRB(30, 10, 30, 10);
    final buttonOpacity = ref.watch(buttonOpacityProvider);
    final icon = Padding(padding: padding, child: child);
    final dec = BoxDecoration(color: Colors.grey.withOpacity(buttonOpacity), borderRadius: BorderRadius.circular(30));
    final border = BorderRadius.circular(30.0);
    return Material(color: Colors.transparent, child: InkWell(customBorder: RoundedRectangleBorder(borderRadius: border), 
      onTapDown: (_)=>game.directionDown(direction),
      onTapUp: (_)=>game.directionUp(direction),
      onTapCancel: ()=>game.directionUp(direction),
      child: Ink(decoration: dec, child: icon)));
  }
}
