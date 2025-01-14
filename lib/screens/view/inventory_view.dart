import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karas_quest/components/game.dart';
import 'package:karas_quest/control/constants.dart';
import 'package:karas_quest/control/enum/ui_view_type.dart';
import 'package:karas_quest/control/json/item.dart';
import 'package:karas_quest/control/provider/inventory_item_provider.dart';
import 'package:karas_quest/control/provider/inventory_provider.dart';
import 'package:karas_quest/control/provider/ui_provider.dart';

class InventoryView extends ConsumerWidget {
  final MainGame game;
  const InventoryView(this.game, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerData = ref.watch(inventoryProvider);
    final width = MediaQuery.of(context).size.width;
    final title = _title(context);
    final cells = playerData.inventory.map((item) => _buildCell(context, item, ref)).toList();
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

  Widget _title(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const titleStyle = TextStyle(fontSize: 18, color: Colors.white);
    const label = Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text('Inventory', style: titleStyle));
    return Padding(padding: const EdgeInsets.only(bottom: 1), child:Container(
        constraints: BoxConstraints(maxWidth: width),
        decoration: boxDecoration,
        child: label));
  }

  Widget _buildCell(BuildContext context, Item item, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isEquipped = item.isEquipped ? ' *' : '';
    final name = Padding(padding: const EdgeInsets.all(5), child: Text('${item.name} $isEquipped', style: titleStyle));
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
          ref.read(inventoryItemProvider.notifier).set(item);
          item.isSelected = true;
        },
        child: paddedContainer);
  }

  Widget _descriptionPane(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width - 2;
    final item = ref.watch(inventoryItemProvider);
    const style = TextStyle(fontSize: 16, color: Colors.white);
    final isEquipped = item.isEquipped ? '* Equipped' : '';
    final value = item.value == 0 ? '' : '+${item.value} ${item.valueName}';
    final description = '${item.name}\n\n${item.description}\n\n$value\n\n$isEquipped';
    final label = Padding(
        padding: const EdgeInsets.all(5),
        child: Text(description, style: style));
    final decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        color: mainColor);

    const deleteIcon = Icon(Icons.delete, size: 24, color: Colors.white);
    final useText = Padding(padding: const EdgeInsets.all(5), child: Text(item.inventoryUseText, style: style));

    final buttonStyle = ButtonStyle(elevation: WidgetStateProperty.resolveWith<double>((states) {
      if(states.contains(WidgetState.pressed)) {
        return 0;
      } else {
        return 5;
      }
    }), backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if(states.contains(WidgetState.pressed)) {
        return mainColor;
      } else {
        return borderColor;
      }
    }));

    final deleteBtn = ElevatedButton(
      style: buttonStyle,
        onPressed: () {
          game.player.data.delete(item);
          if(game.player.weapon == item) {
            game.player.weapon = Item()..value = 1;
          }
          if(game.player.armor == item) {
            game.player.armor = Item();
          }
          ref.read(inventoryProvider.notifier).set(game.player.data);
          if (game.player.data.inventory.isNotEmpty) {
            ref
                .read(inventoryItemProvider.notifier)
                .set(game.player.data.inventory.first);
          } else {
            ref.read(inventoryItemProvider.notifier).set(Item());
          }
        },
        child: const Center(child: deleteIcon));

    final useButton = ElevatedButton(
      style: buttonStyle,
      onPressed: () {
        game.mapRunner?.useItem(item);
        ref.read(inventoryProvider.notifier).set(game.player.data);
        if (game.player.data.inventory.isNotEmpty) {
          ref
              .read(inventoryItemProvider.notifier)
              .set(game.player.data.inventory.first);
        } else {
          ref.read(inventoryItemProvider.notifier).set(Item());
        }
      },
      child: useText,
    );

    final buttonRow = Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(children: [useButton, const Spacer(), deleteBtn]));
    final col = Column(children: [label, const Spacer(), buttonRow]);
    return Padding(padding: const EdgeInsets.only(right:1), child:Container(
        height: 400, width: width / 2, decoration: decoration, child: col));
  }
}
