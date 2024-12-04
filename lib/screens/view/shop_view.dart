import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/enum/ui_view_type.dart';
import 'package:karas_quest/control/json/item.dart';
import 'package:karas_quest/control/json/shop.dart';
import 'package:karas_quest/control/provider/shop_item_provider.dart';
import 'package:karas_quest/control/provider/shop_provider.dart';
import 'package:karas_quest/control/provider/ui_provider.dart';

class ShopMenu extends ConsumerWidget {
  final MainGame game;
  const ShopMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(shopProvider);
    final width = MediaQuery.of(context).size.width;
    final title = _title(context, shop);
    final cells = shop.items.map((item) => _buildCell(context, item, ref)).toList();
    final rightCol = SizedBox(height: 300, child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: Column(children: cells)));
    final leftCol = Column(children: [_descriptionPane(context, ref)]);
    final row = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [leftCol, rightCol]);

    final closeBtnContainer = InkWell(
      onTap: () => ref.read(uiProvider.notifier).set(UIViewDisplayType.game), 
      child: Padding(padding: const EdgeInsets.only(top: 30), 
        child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
        boxShadow: const [BoxShadow(offset: Offset(0, 1), blurRadius: 5, spreadRadius: 1, color: Colors.black45)],
        borderRadius: BorderRadius.circular(30), 
        color: Colors.grey[600]), 
        child: const Icon(Icons.close, size: 24, color: Colors.white))));  

    final col = Column(mainAxisAlignment: MainAxisAlignment.center, children: [title, row, closeBtnContainer]);
    final box =
        Center(child: SizedBox(width: width, child: col));
    return box;
  }

  Widget _title(BuildContext context, Shop shop) {
    final width = MediaQuery.of(context).size.width;
    const titleStyle = TextStyle(fontSize: 18, color: Colors.white);
    final label = Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(shop.owner, style: titleStyle));
    final decoration = BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(borderRadius),
        color: mainColor);
    return Padding(padding: const EdgeInsets.only(bottom: 1), child:Container(
        constraints: BoxConstraints(maxWidth: width),
        decoration: decoration,
        child: label));
  }

  Widget _buildCell(BuildContext context, Item item, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    const titleStyle = TextStyle(fontSize: 18, color: Colors.white);
    final name = Padding(padding: const EdgeInsets.all(5), child: Text(item.name, style: titleStyle));
    final row = Row(children: [name]);

    final color = item.isSelected ? selectedColor : mainColor;
 
    final decoration = BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
        color: color,
        borderRadius: BorderRadius.circular(borderRadius));

    final container = Container(
        constraints: BoxConstraints(maxWidth: width / 2),
        decoration: decoration,
        child: row);

    final paddedContainer =
        Padding(padding: const EdgeInsets.only(bottom: 1), child: container);

    return InkWell(
        onTap: () {
          ref.read(shopItemProvider.notifier).set(item);
          item.isSelected = true;
        },
        child: paddedContainer);
  }


  Widget _descriptionPane(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width - 2;
    final item = ref.watch(shopItemProvider);
    const style = TextStyle(fontSize: 18, color: Colors.white);
    final value = item.value == 0 ? '' : '+${item.value} ${item.valueName}';
    final description = '${item.name}\n\n${item.description}\n\n$value\n\nCost: ${item.cost} gold';
    final label = Padding(
        padding: const EdgeInsets.all(5),
        child: Text(description, style: style));
    final decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        color: mainColor);
    const useText = Padding(padding: EdgeInsets.all(5), child: Text('Buy', style: style));
    final buttonStyle = ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if(states.contains(WidgetState.pressed)) {
        return mainColor;
      } else {
        return borderColor;
      }
    }));

    final useButton = ElevatedButton(
      style: buttonStyle,
      onPressed: () {
        MainGame.instance.mapRunner!.playerBoughtItem(item);
      },
      child: useText,
    );

    final buttonRow = Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [useButton]));
    final col = Column(children: [label, const Spacer(), buttonRow]);
    return Padding(padding: const EdgeInsets.only(right:1), child:Container(
        height: 400, width: width / 2, decoration: decoration, child: col));
  }
}
