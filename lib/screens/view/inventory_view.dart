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
    final rightCol = SizedBox(height: 300, child: SingleChildScrollView(child: Column(children: cells), physics: AlwaysScrollableScrollPhysics()));
    final leftCol = Column(children: [_descriptionPane(context, ref)]);
    final row = Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [leftCol, rightCol]);
    final col = Column(children: [title, row]);
    final box = Center(child: SizedBox(width: width, height: width, child: col));
    return box;
  }

  Widget _title(context) {
    final width = MediaQuery.of(context).size.width;
    final titleStyle = TextStyle(fontSize: 18, color: Colors.white);
    final label = Padding(padding: EdgeInsets.fromLTRB(10, 5, 10, 5), child: Text('Inventory', style: titleStyle));
    final decoration = BoxDecoration(border: Border.all(color: Color.fromARGB(255, 173, 91, 20), width: 4), color: Color.fromARGB(255, 82, 41, 4));
    return Container(constraints: BoxConstraints(maxWidth: width), decoration: decoration, child: label);
  }

  Widget _buildCell(BuildContext context, InventoryItem item, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final titleStyle = TextStyle(fontSize: 18, color: Colors.white);
    final name = Padding(padding: EdgeInsets.all(5), child: Text(item.name, style: titleStyle));
    final row = Row(children: [name]);
    final decoration = BoxDecoration(border: Border.all(color: Color.fromARGB(255, 173, 91, 20), width: 4), color: Color.fromARGB(255, 82, 41, 4));
    final container = Container(constraints: BoxConstraints(maxWidth: width/2), decoration: decoration, child: row);
    return InkWell(onTap: (){
      ref.read(inventoryItemProvider.notifier).set(item);
    }, child: container);
  }

  Widget _descriptionPane(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final item = ref.watch(inventoryItemProvider);
    final style = TextStyle(fontSize: 18, color: Colors.white);
    final label = Padding(padding: EdgeInsets.all(5), child:Text(item.description, style: style));
    final decoration = BoxDecoration(border: Border.all(color: Color.fromARGB(255, 173, 91, 20), width: 4), color: Color.fromARGB(255, 82, 41, 4));
    final deleteIcon = Icon(Icons.delete, size: 36, color: Colors.grey);
    final useText = Padding(padding: EdgeInsets.all(5), child: Text('Use', style: style));

    final useBtn = InkWell(onTap: (){
      game.overworld?.useItem(item);
      ref.read(inventoryProvider.notifier).set(game.overworld!.inventory);
      if(game.overworld!.inventory.items.isNotEmpty){
        ref.read(inventoryItemProvider.notifier).set(game.overworld!.inventory.items.first);
      } else {
        ref.read(inventoryItemProvider.notifier).set(InventoryItem());
      }
    }, child:Container(decoration: decoration, child: useText));
    final deleteBtn = InkWell(onTap: (){
      game.overworld?.inventory.delete(item);
      ref.read(inventoryProvider.notifier).set(game.overworld!.inventory);
      if(game.overworld!.inventory.items.isNotEmpty){
        ref.read(inventoryItemProvider.notifier).set(game.overworld!.inventory.items.first);
      } else {
        ref.read(inventoryItemProvider.notifier).set(InventoryItem());
      }
    }, child:Container(decoration: decoration, child: Center(child:deleteIcon)));

    final buttonRow = Row(children: [useBtn, const Spacer(), deleteBtn]);
    final col = Column(children: [label, const Spacer(), buttonRow]);
    return Container(height: 300, width: width/2, decoration: decoration, child: col);
  }
}
