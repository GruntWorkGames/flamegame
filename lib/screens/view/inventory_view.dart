import 'package:flame_game/constants.dart';
import 'package:flame_game/control/json/inventory.dart';
import 'package:flame_game/control/provider/inventory_item_provider.dart';
import 'package:flame_game/control/provider/inventory_provider.dart';
import 'package:flame_game/screens/components/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryView extends ConsumerWidget {
  final MainGame game;
  InventoryView(this.game);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryData = ref.watch(inventoryProvider);
    final width = MediaQuery.of(context).size.width;
    final title = _title(context);
    final cells = inventoryData.items.map((item) => _buildCell(context, item, ref)).toList();
    final rightCol = SizedBox(height: 300, child: SingleChildScrollView(child: Column(children: cells),
      physics: AlwaysScrollableScrollPhysics()));
    final leftCol = Column(children: [_descriptionPane(context, ref)]);
    final row = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [leftCol, rightCol]);
    final col = Column(children: [title, row]);
    final box =
        Center(child: SizedBox(width: width, height: width, child: col));
    return box;
  }

  Widget _title(context) {
    final width = MediaQuery.of(context).size.width;
    final titleStyle = TextStyle(fontSize: 18, color: Colors.white);
    final label = Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text('Inventory', style: titleStyle));
    final decoration = BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(borderRadius),
        color: mainColor);
    return Padding(padding: EdgeInsets.only(bottom: 1), child:Container(
        constraints: BoxConstraints(maxWidth: width),
        decoration: decoration,
        child: label));
  }

  Widget _buildCell(BuildContext context, InventoryItem item, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final titleStyle = TextStyle(fontSize: 18, color: Colors.white);
    final name = Padding(padding: EdgeInsets.all(5), child: Text(item.name, style: titleStyle));
    final row = Row(children: [name]);

    final decoration = BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
        color: mainColor,
        borderRadius: BorderRadius.circular(borderRadius));

    final container = Container(
        constraints: BoxConstraints(maxWidth: width / 2),
        decoration: decoration,
        child: row);

    final paddedContainer =
        Padding(padding: EdgeInsets.only(bottom: 1), child: container);

    return InkWell(
        onTap: () {
          ref.read(inventoryItemProvider.notifier).set(item);
        },
        child: paddedContainer);
  }

  Widget _descriptionPane(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width - 2;
    final item = ref.watch(inventoryItemProvider);
    final style = TextStyle(fontSize: 18, color: Colors.white);
    final label = Padding(
        padding: EdgeInsets.all(5),
        child: Text(item.description, style: style));
    final decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        color: mainColor);
    final deleteIcon = Icon(Icons.delete, size: 36, color: Colors.white);
    final useText =
        Padding(padding: EdgeInsets.all(5), child: Text('Use', style: style));

    final buttonStyle = ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      if(states.contains(MaterialState.pressed)) {
        return mainColor;
      } else {
        return borderColor;
      }
    }));

    final deleteBtn = ElevatedButton(
      style: buttonStyle,
        onPressed: () {
          game.overworld?.inventory.delete(item);
          ref.read(inventoryProvider.notifier).set(game.overworld!.inventory);
          if (game.overworld!.inventory.items.isNotEmpty) {
            ref
                .read(inventoryItemProvider.notifier)
                .set(game.overworld!.inventory.items.first);
          } else {
            ref.read(inventoryItemProvider.notifier).set(InventoryItem());
          }
        },
        child: Center(child: deleteIcon));

    final useButton = ElevatedButton(
      style: buttonStyle,
      onPressed: () {
        game.overworld?.useItem(item);
        ref.read(inventoryProvider.notifier).set(game.overworld!.inventory);
        if (game.overworld!.inventory.items.isNotEmpty) {
          ref
              .read(inventoryItemProvider.notifier)
              .set(game.overworld!.inventory.items.first);
        } else {
          ref.read(inventoryItemProvider.notifier).set(InventoryItem());
        }
      },
      child: useText,
    );

    final buttonRow = Row(children: [useButton, const Spacer(), deleteBtn]);
    final col = Column(children: [label, const Spacer(), buttonRow]);
    return Padding(padding: EdgeInsets.only(right:1), child:Container(
        height: 300, width: width / 2, decoration: decoration, child: col));
  }
}
