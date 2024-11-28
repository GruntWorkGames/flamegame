import 'package:flame_game/control/json/character_data.dart';

class SaveFile {
  CharacterData playerData = CharacterData();

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