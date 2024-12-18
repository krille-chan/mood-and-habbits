extension SameDayExtension on DateTime {
  bool isSameDay(DateTime other) =>
      day == other.day && month == other.month && year == other.year;

  DateTime get dateOnly => DateTime(
        year,
        month,
        day,
      );
}
