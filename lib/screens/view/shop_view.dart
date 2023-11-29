import 'dart:ui';
import 'package:flame_game/constants.dart';
import 'package:flame_game/control/enum/ui_view_type.dart';
import 'package:flame_game/control/json/shop.dart';
import 'package:flame_game/control/provider/shop_provider.dart';
import 'package:flame_game/control/provider/ui_provider.dart';
import 'package:flame_game/screens/components/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShopMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(shopProvider);
    // create title box
    final titleStyle = TextStyle(fontSize: 18, color: Colors.white);
    final titleText = Padding(padding: EdgeInsets.all(5), child: Text(shop.owner, style: titleStyle));
    final decoration = BoxDecoration(borderRadius: BorderRadius.circular(borderRadius), border: Border.all(color: borderColor, width: borderWidth), color: mainColor);
    final title = Container(decoration: decoration, child: titleText);

    // create message box
    final mText = Padding(padding: EdgeInsets.all(5), child: Text(shop.message, style: titleStyle));
    final box = ConstrainedBox(constraints: BoxConstraints(maxWidth: 400, maxHeight: 400), child: mText);
    final message = Container(decoration: decoration, child: box);

    // create buy options
    final items = _buildItemCells(shop, ref);

    const spacer = SizedBox(height: 4);
    final column = Column(mainAxisAlignment: MainAxisAlignment.center, children: [title, spacer, message, spacer, ... items]);
    final blur =  BackdropFilter(filter:ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Center(child: column));
    return GestureDetector(onTap: (){
      ref.read(uiProvider.notifier).set(UIViewDisplayType.game);
    }, child: blur);
  }

  List<Widget> _buildItemCells(Shop shop, WidgetRef ref) {
    return shop.items.map((item) {
      return _buildItemCell(item, ref);
    }).toList();
  }

  Widget _buildItemCell(ShopItem item, WidgetRef ref) {
    final titleStyle = TextStyle(fontSize: 18, color: Colors.white);
    final titleText = Padding(padding: EdgeInsets.all(5), child: Text(item.name, style: titleStyle));
    final costText = Padding(padding: EdgeInsets.all(5), child: Text(item.cost.toString(), style: titleStyle));
    final decoration = BoxDecoration(borderRadius: BorderRadius.circular(borderRadius), border: Border.all(color: borderColor, width: borderWidth), color: mainColor);
    final row = Row(children: [titleText, const Spacer(), costText]);
    final cell = Container(decoration: decoration, child: row);
    final touchableCell = InkWell(onTap: (){
      MainGame.instance.overworld!.playerBoughtItem(item);
    }, child: cell);
    return touchableCell;
  }
}