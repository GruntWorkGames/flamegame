import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShopMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackdropFilter(filter:ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Center(child: Text('SHOP', style: TextStyle(fontSize: 46))));
  }
}