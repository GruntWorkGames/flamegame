import 'package:flame_game/control/constants.dart';
import 'package:flame_game/control/enum/control_style.dart';
import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/provider/button_opacity.dart';
import 'package:flame_game/control/provider/control_style_provider.dart';
import 'package:flame_game/control/provider/gold_provider.dart';
import 'package:flame_game/control/provider/healthProvider.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flame_game/control/enum/direction.dart';
import 'package:flame_game/components/game.dart';
import 'package:flame_game/screens/view/control_pad.dart';
import 'package:flame_game/screens/view/debug_view.dart';
import 'package:flame_game/screens/view/dialog_view.dart';
import 'package:flame_game/screens/view/inventory_view.dart';
import 'package:flame_game/screens/view/settings_view.dart';
import 'package:flame_game/screens/view/shop_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class UILayer extends ConsumerWidget {
  late final MainGame game;
  UILayer(this.game);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(uiProvider);
    game.ref = ref;

    final buttonOpacity = ref.watch(buttonOpacityProvider);
    final style = TextStyle(color: Colors.white);
    final hud = _buildHud(ref);
    final gearIcon = Icon(Icons.menu, color: Colors.white);
    final xIcon = Icon(Icons.close, color: Colors.white);
    final fab = SpeedDial(
      child: gearIcon,
      activeChild: xIcon,
      backgroundColor: Colors.grey[buttonId]!.withOpacity(buttonOpacity + 0.1),
      spacing: 3,
      spaceBetweenChildren: 4,
      overlayOpacity: 0,
      direction: SpeedDialDirection.down,
      childrenButtonSize: Size(150, 50),
      children: [
        SpeedDialChild(
          backgroundColor: Colors.grey[buttonId]!.withOpacity(buttonOpacity),
          child: Text('Inventory', style: style), 
          onTap: () => ref.read(uiProvider.notifier).set(UIViewDisplayType.inventory)), 
        SpeedDialChild(
          backgroundColor: Colors.grey[buttonId]!.withOpacity(buttonOpacity),
          child: Text('Settings', style: style), onTap: () => ref.read(uiProvider.notifier).set(UIViewDisplayType.settings)),
        SpeedDialChild(
          backgroundColor: Colors.grey[buttonId]!.withOpacity(buttonOpacity),
          child: Text('Debug', style: style), 
          onTap: () => ref.read(uiProvider.notifier).set(UIViewDisplayType.debug))]);
    const pos = FloatingActionButtonLocation.endTop;

    switch(uiState) {
      case UIViewDisplayType.game:
        return SafeArea(child: Scaffold(backgroundColor: Colors.transparent, 
        body: Stack(children:[_gameOverlay(context, ref), hud]), 
        floatingActionButtonLocation: pos, floatingActionButton: fab));
      case UIViewDisplayType.shop:
        return SafeArea(child: Stack(children: [ShopMenu(game), hud]));
      case UIViewDisplayType.dialog:
        return SafeArea(child: Stack(children:[DialogView(), hud]));
      case UIViewDisplayType.invisible:
        return SizedBox.shrink();
      case UIViewDisplayType.gameOver:
        return _gameOver(ref);
      case UIViewDisplayType.inventory:
        return SafeArea(child: Stack(children:[InventoryView(game), hud]));  
      case UIViewDisplayType.debug: 
        return SafeArea(child: Stack(children:[DebugView(game), hud]));
      case UIViewDisplayType.settings:
        return SafeArea(child: Stack(children:[SettingsView(), hud]));
    }
  }

  Widget _gameOverlay(BuildContext context, WidgetRef ref) {
    final controlStyle = ref.watch(controlStyleState);
    switch(controlStyle) {
      case ControlStyle.directional:
        return Center(child: ControlPad(game));
      case ControlStyle.swipe:
        return Center(child: _buildSwipeDetector());
    }
  }

  Widget _buildHud(WidgetRef ref) {
    final style = TextStyle(color: Colors.white, fontSize: 24);
    final health = ref.watch(healthProvider);
    final heartImg = Transform.scale(scale: 2, filterQuality: FilterQuality.none, child: Image.asset('assets/images/heart.png'));
    final healthText = Padding(padding: EdgeInsets.only(left: 20), child: Text(health.toInt().toString(), style: style));

    final coins = ref.watch(goldProvider);
    final coinImg = Transform.scale(scale: 2, filterQuality: FilterQuality.none, child: Image.asset('assets/images/coin.png'));
    final coinText = Padding(padding: EdgeInsets.only(left: 20), child: Text(coins.toInt().toString(), style: style));

    final healthRow = Row(children: [heartImg, healthText]);
    final goldRow = Row(children: [coinImg, coinText]);
    final column = Padding(padding: EdgeInsets.all(10), child: Column(children: [healthRow, goldRow]));
    final touchableColumn = GestureDetector(onTap: ()=>ref.read(uiProvider.notifier).set(UIViewDisplayType.game), child: column);
    return touchableColumn;
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
      // TODO
    }, child: DialogView());
    return Center(child: dialog);
  }
  
}