import 'package:flame_game/control/provider/inventory_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryData = ref.watch(inventoryProvider);
    return Container();
  }
}
