import 'package:karas_quest/control/json/character_data.dart';
import 'package:karas_quest/control/json/overworld_data.dart';
import 'package:karas_quest/control/json/quest.dart';

class SaveFile {
  CharacterData playerData = CharacterData();
  List<Quest> activeQuests = [];
  List<Quest> completedQuests = [];
  List<String> completedQuestIds = [];
  List<CharacterData> enemies = [];
  List<MapData> mapStack = [];
  bool isFreshGame = true;

  SaveFile();

  SaveFile.fromMap(Map<String, dynamic> map) {
    final playerNode = map['player'] as Map<String, dynamic>? ?? {};
    isFreshGame = map['isFreshGame'] as bool? ?? true;
    final questsList = map['activeQuests'] as List<dynamic>? ?? [];
    activeQuests = questsList.map((map) {
      final node = map as Map<String, dynamic>? ?? {};
      return Quest.fromMap(node);
    }).toList();

    final completedQuestsList = map['completedQuests'] as List<dynamic>? ?? [];
    completedQuests = completedQuestsList.map((map) {
      final node = map as Map<String, dynamic>? ?? {};
      return Quest.fromMap(node);
    }).toList();

    playerData = CharacterData.fromMap(playerNode);

    final mapNode = map['mapStack'] as List<dynamic>? ?? [];

    mapStack = mapNode.map((map) {
      final mapNode = map as Map<String, dynamic>? ?? {};
      return MapData.fromJson(mapNode);  
    }).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'isFreshGame' : false,
      'player' : playerData.toMap(),
      'activeQuests' : activeQuests.map((quest) => quest.toMap()).toList(),
      'completedQuests' : completedQuests.map((quest) => quest.toMap()).toList(),
      'mapStack' : mapStack.map((map)=>map.toMap()).toList()
    };
  }
}