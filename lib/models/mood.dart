class Mood {
  final int? databaseId;
  final MoodValue mood;
  final DateTime dateTime;

  const Mood({
    this.databaseId,
    required this.mood,
    required this.dateTime,
  });

  static const String databaseRowName = 'mood';

  Map<String, Object?> toDatabaseRow() => {
        if (databaseId != null) 'id': databaseId,
        'mood': mood.value,
        'time': dateTime.millisecondsSinceEpoch,
      };

  factory Mood.fromDatabaseRow(Map<String, Object?> row) => Mood(
        databaseId: row['id'] as int,
        mood: MoodValue.values.singleWhere((mood) => mood.value == row['mood']),
        dateTime: DateTime.fromMillisecondsSinceEpoch(row['time'] as int),
      );
}

enum MoodValue {
  great('😃', 5),
  good('🙂', 4),
  neutral('😐', 3),
  bad('😟', 2),
  awful('😭', 1);

  final String emoji;
  final int value;
  const MoodValue(this.emoji, this.value);
}
