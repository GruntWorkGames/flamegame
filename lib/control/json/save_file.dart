import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveFileController {
  SaveFile saveFile = SaveFile();

  SaveFileController();

  SaveFileController.fromMap(Map<String, dynamic> map) {
    saveFile = SaveFile.fromMap(map);
  }

  Future<void> loadDefaultFile() async {
    debugPrint('loading default quest file');
    try {
      final saveFileJson = await rootBundle.loadString('assets/json/save_file.json');
      final saveMap = jsonDecode(saveFileJson) as Map<String, dynamic>? ?? {};
      saveFile = SaveFile.fromMap(saveMap);
    } on Exception catch(e, s) {
      debugPrint('$e \n $s');
    }
  }

  Future<void> save() async {
    final jsonString = jsonEncode(saveFile.toMap());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('save_file', jsonString);
  }

  Future<void> loadFromStorage() async {
    try{
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('save_file') ?? '{}';
      final map = jsonDecode(json) as Map<String, dynamic>? ?? {};
      saveFile = SaveFile.fromMap(map);
      debugPrint('loaded saved quest file');
    } on Exception catch(e, s) {
      debugPrint('$e \n $s');
      loadDefaultFile();
    }
  }
}

class SaveFile {
  SaveFile();
  
  List<String> completedQuestIds = [];

  SaveFile.fromMap(Map<String, dynamic> map) {
    _loadCompletedQuests(map);
  }

  void _loadCompletedQuests(Map<String, dynamic> mainMap) {
    final completedQuestList = mainMap['completedQuests'] as List<String>? ?? [];
    for(final questId in completedQuestList) {
      completedQuestIds.add(questId);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'completedQuestIds': completedQuestIds,
    };
  }
}