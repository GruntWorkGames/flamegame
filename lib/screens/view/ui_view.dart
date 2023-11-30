import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/provider/gold_provider.dart';
import 'package:flame_game/control/provider/healthProvider.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flame_game/direction.dart';
import 'package:flame_game/screens/components/game.dart';
import 'package:flame_game/screens/view/dialog_view.dart';
import 'package:flame_game/screens/view/inventory_view.dart';
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

    final hud = _buildHud(ref);

    switch(uiState) {
      case UIViewDisplayType.game:
        return SafeArea(child: Stack(children:[_gameOverlay(context, ref), hud]));
      case UIViewDisplayType.shop:
        final stack = SafeArea(child: Stack(children: [ShopMenu(game), hud]));
        return stack;
      case UIViewDisplayType.dialog:
        return SafeArea(child: Stack(children:[DialogView(), hud]));
      case UIViewDisplayType.invisible:
        return SizedBox.shrink();
      case UIViewDisplayType.gameOver:
        return _gameOver(ref);
      case UIViewDisplayType.inventory:q
        return SafeArea(child: Stack(children:[InventoryView(game), hud]));  
    }
  }

  Widget _gameOverlay(BuildContext context, WidgetRef ref) {
    return Center(child: ControlPad(game));
  }

  Widget _buildHud(WidgetRef ref) {
    final style = TextStyle(color: Colors.white, fontSize: 24);
    final health = ref.watch(healthProvider);
    final heartImg = Transform.scale(scale: 2, filterQuality: FilterQuality.none, child: Image.asset('assets/images/heart.png'));
    final healthText = Padding(padding: EdgeInsets.only(left: 20), child: Text(health.toString(), style: style));

    final coins = ref.watch(goldProvider);
    final coinImg = Transform.scale(scale: 2, filterQuality: FilterQuality.none, child: Image.asset('assets/images/coin.png'));
    final coinText = Padding(padding: EdgeInsets.only(left: 20), child: Text(coins.toString(), style: style));

    final healthRow = Row(children: [heartImg, healthText]);
    final goldRow = Row(children: [coinImg, coinText]);
    final column = Padding(padding: EdgeInsets.all(10), child: Column(children: [healthRow, goldRow]));
    return column;
  }

  Widget _buildSwipeDetector() {
    return GestureDetector(onHorizontalDragEnd: (drag) {
      final v = drag.velocity.pixelsPerSecond;
      if (v.dx > 0) {
        game.directionPressed(Direction.right);
      }
      if (v.dx < 0) {
        game.directionPressed(Direction.left);
      }
    }, onVerticalDragEnd: (drag) {
      final v = drag.velocity.pixelsPerSecond;
      if (v.dy > 0) {
        game.directionPressed(Direction.down);
      }
      if (v.dy < 0) {
        game.directionPressed(Direction.up);
      }
    });
  }
  
  Widget _gameOver(WidgetRef ref) {
    final dialog = GestureDetector(onTap: (){
      game.overworldNavigator.loadNewGame();
    }, child: DialogView());
    return Center(child: dialog);
  }
}

class ControlPad extends ConsumerWidget {
  final MainGame game;

  ControlPad(this.game);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Colors.white;
    final upIcon = Padding(padding: EdgeInsets.all(10), child: Transform.rotate(
        angle: 90 * 3.14 / 180, child: Icon(Icons.chevron_left, color: color)));

    final downIcon = Padding(padding: EdgeInsets.all(10), child: Transform.rotate(
        angle: -90 * 3.14 / 180, child: Icon(Icons.chevron_left, color: color)));
    final leftIcon = Padding(padding: EdgeInsets.all(10), child: Icon(Icons.chevron_left, color: color));
    final rightIcon = Padding(padding: EdgeInsets.all(10), child: Icon(Icons.chevron_right, color: color));

    final style = ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      if(states.contains(MaterialState.pressed)) {
        return Colors.grey[700]!.withOpacity(0.3);
      } else {
        return Colors.grey[400]!.withOpacity(0.3);
      }
    }));

    final upButton = ElevatedButton(onPressed: (){game.directionPressed(Direction.up);}, child: upIcon, style: style);
    final downButton = ElevatedButton(onPressed: (){game.directionPressed(Direction.down);}, child: downIcon, style: style);
    final leftButton = ElevatedButton(onPressed: (){game.directionPressed(Direction.left);}, child: leftIcon, style: style);
    final rightButton = ElevatedButton(onPressed: (){game.directionPressed(Direction.right);}, child: rightIcon, style: style);

    final topRow =Row(mainAxisAlignment: MainAxisAlignment.center, children: [upButton]);
    final middleRow = Padding(padding: EdgeInsets.symmetric(horizontal: 10), 
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [leftButton, rightButton]));
    final bottomRow = Padding(padding: EdgeInsets.only(bottom: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [downButton]));

    return Column(children: [const Spacer(), topRow, middleRow, bottomRow]);
  }
}
