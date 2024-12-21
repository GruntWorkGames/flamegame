import 'package:flame/extensions.dart';

class NpcData {
  String speech = '';
  List<String> speeches = [];
  String name = '';
  String shopJsonFile = '';
  String animationJsonFile = '';
  String spriteFile = '';
  Vector2 position = Vector2.zero();
  List<String> questsAvailable = [];
 
  NpcData();

  NpcData.fromMap(Map<String, dynamic> map) {
    name = map['name'] as String? ?? '';
    final quests = map['questsAvailable'] as List<dynamic>? ?? [];
    for(final quest in quests) {
      if(quest is String) {
        questsAvailable.add(quest);
      }
    }
    speech = map['speech'] as String? ?? '';
    speeches = map['speeches'] as List<String>? ?? [];
    shopJsonFile = map['shopFile'] as String? ?? '';
    animationJsonFile = map['animationFile'] as String? ?? '';
    spriteFile = map['sprite'] as String? ?? '';
  }
}
