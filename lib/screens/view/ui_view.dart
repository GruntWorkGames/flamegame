import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/components/game.dart';
import 'package:flame_game/screens/view/dialog_view.dart';
import 'package:flame_game/screens/view/shop_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UIView extends ConsumerWidget {
  late final MainGame game;
  UIView(this.game);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(uiProvider);
    game.ref = ref;

    if (uiState == UIViewDisplayType.game) {
      return _gameOverlay(context, ref, game);
    }

    if (uiState == UIViewDisplayType.shop) {
      return ShopMenu();
    }

    if (uiState == UIViewDisplayType.dialog) {
      return DialogView();
    }

    return SizedBox.shrink();
  }

  Widget _gameOverlay(BuildContext context, WidgetRef ref, MainGame game) {
    final detector = GestureDetector(onHorizontalDragEnd: (drag) {
    final v = drag.velocity.pixelsPerSecond;
    if(v.dx > 0) {
      game.directionPressed(Direction.right);
    }
    if(v.dx < 0) {
      game.directionPressed(Direction.left);
    }
    }, onVerticalDragEnd: (drag) {
      final v = drag.velocity.pixelsPerSecond;
      if(v.dy > 0) {
        game.directionPressed(Direction.down);
      }
      if(v.dy < 0) {
        game.directionPressed(Direction.up);
      }
    });
    return detector;
  }
}

class ControlPad extends ConsumerWidget {
  final MainGame game;

  ControlPad(this.game);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upIcon = Transform.rotate(
        angle: 90 * 3.14 / 180, child: Icon(Icons.chevron_left));
    final upButton = _buttonWithIcon(upIcon, () {});
    return Container();
  }

  Widget _buttonWithIcon(Widget icon, Function function) {
    return InkWell(
        onTap: () {
          function();
        },
        child: Padding(padding: EdgeInsets.all(36), child: icon));
  }
}
