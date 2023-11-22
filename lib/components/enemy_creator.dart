import 'dart:math';
import 'package:flame/components.dart';

class EnemyCreator extends TimerComponent with HasGameRef {
  final Random random = Random();

  EnemyCreator() : super(period: 0.1, repeat: true);

  @override
  void onTick() {
    // gameRef.addAll(
    //   List.generate(
    //     1,
    //     (index) => Enemy(
    //       position: Vector2(
    //         16 + (gameRef.size.x - 16) * random.nextDouble(),
    //         0,
    //       ),
    //     ),
    //   ),
    // );
  }
}
