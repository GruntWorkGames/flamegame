import 'package:karas_quest/control/json/character_data.dart';
import 'package:karas_quest/control/json/quest.dart';

class SaveFile {
  CharacterData playerData = CharacterData();
  List<Quest> currentQuests = [];
  List<Quest> completedQuests = [];
  List<Quest> allQuests = [];

  SaveFile();
  
  List<String> completedQuestIds = [];

  SaveFile.fromMap(Map<String, dynamic> map) {
    final playerNode = map['player'] as Map<String, dynamic>? ?? {};
    playerData = CharacterData.fromMap(playerNode);
  }

  Map<String, dynamic> toMap() {
    return {
      'player' : playerData.toMap()
    };
  }
}