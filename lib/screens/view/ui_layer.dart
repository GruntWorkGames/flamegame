import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/enum/control_style.dart';
import 'package:karas_quest/control/enum/direction.dart';
import 'package:karas_quest/control/enum/ui_view_type.dart';
import 'package:karas_quest/control/provider/button_opacity.dart';
import 'package:karas_quest/control/provider/control_style_provider.dart';
import 'package:karas_quest/control/provider/gold_provider.dart';
import 'package:karas_quest/control/provider/health_provider.dart';
import 'package:karas_quest/control/provider/ui_provider.dart';
import 'package:karas_quest/screens/view/control_pad.dart';
import 'package:karas_quest/screens/view/debug_view.dart';
import 'package:karas_quest/screens/view/dialog_view.dart';
import 'package:karas_quest/screens/view/inventory_view.dart';
import 'package:karas_quest/screens/view/quest_giver_view.dart';
import 'package:karas_quest/screens/view/quest_list_view.dart';
import 'package:karas_quest/screens/view/settings_view.dart';
import 'package:karas_quest/screens/view/shop_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class UILayer extends ConsumerWidget {
  final MainGame game;
  const UILayer(this.game, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(uiProvider);
    game.ref = ref;

    final buttonOpacity = ref.watch(buttonOpacityProvider);
    const style = TextStyle(color: Colors.white);
    final hud = _buildHud(ref);
    const gearIcon = Icon(Icons.menu, color: Colors.white);
    const xIcon = Icon(Icons.close, color: Colors.white);
    final fab = SpeedDial(
      activeChild: xIcon,
      backgroundColor: Colors.grey[buttonId]!.withOpacity(buttonOpacity + 0.1),
      spacing: 3,
      spaceBetweenChildren: 4,
      overlayOpacity: 0,
      direction: SpeedDialDirection.down,
      childrenButtonSize: const Size(150, 50),
      children: [
        SpeedDialChild(
          backgroundColor: Colors.grey[buttonId]!.withOpacity(buttonOpacity),
          child: const Text('Inventory', style: style), 
          onTap: () => ref.read(uiProvider.notifier).set(UIViewDisplayType.inventory)), 
        SpeedDialChild(
          backgroundColor: Colors.grey[buttonId]!.withOpacity(buttonOpacity),
          child: const Text('Quests', style: style), 
          onTap: () => ref.read(uiProvider.notifier).set(UIViewDisplayType.quests)), 
        SpeedDialChild(
          backgroundColor: Colors.grey[buttonId]!.withOpacity(buttonOpacity),
          child: const Text('Settings', style: style), onTap: () => ref.read(uiProvider.notifier).set(UIViewDisplayType.settings)),
        SpeedDialChild(
          backgroundColor: Colors.grey[buttonId]!.withOpacity(buttonOpacity),
          child: const Text('Debug', style: style), 
          onTap: () => ref.read(uiProvider.notifier).set(UIViewDisplayType.debug))],
      child: gearIcon);
    const pos = FloatingActionButtonLocation.endTop;

    switch(uiState) {
      case UIViewDisplayType.game:
        return SafeArea(child: Scaffold(backgroundColor: Colors.transparent, 
        body: Stack(children:[_gameOverlay(context, ref), hud]), 
        floatingActionButtonLocation: pos, floatingActionButton: fab));
      case UIViewDisplayType.shop:
        return SafeArea(child: Stack(children: [ShopMenu(game), hud]));
      case UIViewDisplayType.dialog:
        return SafeArea(child: Stack(children:[const DialogView(), hud]));
      case UIViewDisplayType.invisible:
        return const SizedBox.shrink();
      case UIViewDisplayType.gameOver:
        return _gameOver(context, ref);
      case UIViewDisplayType.inventory:
        return SafeArea(child: Stack(children:[InventoryView(game), hud]));  
      case UIViewDisplayType.debug: 
        return SafeArea(child: Stack(children:[DebugView(game), hud]));
      case UIViewDisplayType.settings:
        return SafeArea(child: Stack(children:[const SettingsView(), hud]));
      case UIViewDisplayType.quests:  
        return SafeArea(child: Stack(children:[QuestListView(game), hud]));
      case UIViewDisplayType.questGiver:
        return SafeArea(child: Stack(children:[QuestGiverView(game), hud]));
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
    const style = TextStyle(color: Colors.white, fontSize: 24);
    final health = ref.watch(healthProvider);
    final heartImg = Transform.scale(scale: 2, filterQuality: FilterQuality.none, child: Image.asset('assets/images/heart.png'));
    final healthText = Padding(padding: const EdgeInsets.only(left: 20), child: Text(health.toString(), style: style));

    final coins = ref.watch(goldProvider);
    final coinImg = Transform.scale(scale: 2, filterQuality: FilterQuality.none, child: Image.asset('assets/images/coin.png'));
    final coinText = Padding(padding: const EdgeInsets.only(left: 20), child: Text(coins.toString(), style: style));

    final healthRow = Row(children: [heartImg, healthText]);
    final goldRow = Row(children: [coinImg, coinText]);
    final column = Padding(padding: const EdgeInsets.all(10), child: Column(children: [healthRow, goldRow]));
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
  
  Widget _gameOver(BuildContext context, WidgetRef ref) {
    final dialog = GestureDetector(onTap: (){
      Navigator.pop(context);
    }, child: const DialogView(showCloseButton: false));
    return Center(child: dialog);
  }
  
}