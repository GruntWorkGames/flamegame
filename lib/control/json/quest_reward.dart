class QuestReward {
  int xp = 0;

  QuestReward();
  QuestReward.fromMap(Map<String, dynamic> map) {
    xp = map['xp'] as int? ?? 0;
  }
  Map<String, dynamic> toMap() {
    return 
    {
      'xp' : xp
    };
  }
}