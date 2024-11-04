extension SameDayExtension on DateTime {
  bool isSameDay(DateTime other) =>
      day == other.day && month == other.month && year == other.year;
}
