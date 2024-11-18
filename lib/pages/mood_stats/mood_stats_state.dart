import 'package:flutter/material.dart';

import 'package:d_chart/d_chart.dart';

import 'package:mood_n_habits/models/app_state.dart';
import 'package:mood_n_habits/models/mood.dart';
import 'package:mood_n_habits/utils/get_l10n.dart';

class MoodStatsState {
  final AppState appState;

  MoodStatsState(this.appState) {
    calcLineChartData();
  }

  DateTime _date = DateTime.now();

  DateTime get currentDate => _date;

  final ValueNotifier<TimeRange> timeRange = ValueNotifier(TimeRange.today);

  final ValueNotifier<
      ({
        List<TimeData>? lineChartData,
        List<Mood>? moods,
      })> data = ValueNotifier(
    (
      lineChartData: null,
      moods: null,
    ),
  );

  void dateNext() {
    switch (timeRange.value) {
      case TimeRange.today:
        _date = _date.add(const Duration(days: 1));
      case TimeRange.week:
        _date = _date.add(const Duration(days: 7));
      case TimeRange.month:
        if (_date.month < 12) {
          _date = DateTime(_date.year, _date.month + 1, _date.day);
        } else {
          _date = DateTime(_date.year + 1, 1, _date.day);
        }
      case TimeRange.year:
        _date = DateTime(_date.year + 1, _date.month, _date.day);
    }
    calcLineChartData();
  }

  void datePrev() {
    switch (timeRange.value) {
      case TimeRange.today:
        _date = _date.subtract(const Duration(days: 1));
      case TimeRange.week:
        _date = _date.subtract(const Duration(days: 7));
      case TimeRange.month:
        if (_date.month > 1) {
          _date = DateTime(_date.year, _date.month - 1, _date.day);
        } else {
          _date = DateTime(_date.year - 1, 12, _date.day);
        }
      case TimeRange.year:
        _date = DateTime(_date.year - 1, _date.month, _date.day);
    }
    calcLineChartData();
  }

  void dateReset() {
    _date = DateTime.now();
    calcLineChartData();
  }

  void calcLineChartData() async {
    final since = switch (timeRange.value) {
      TimeRange.year => DateTime(_date.year, 1, 1),
      TimeRange.month => DateTime(_date.year, _date.month, 1),
      TimeRange.week => DateTime(_date.year, _date.month, _date.day)
          .subtract(const Duration(days: 7)),
      TimeRange.today => DateTime(_date.year, _date.month, _date.day),
    };

    final until = DateTime(_date.year, _date.month, _date.day, 23, 59, 59);

    final moods = await appState.getMoods(since, until);
    List<Mood>? moodsPerDay;

    // Combine mood average by day
    if (timeRange.value != TimeRange.today) {
      final moodsByDay = <DateTime, List<Mood>>{};
      for (final mood in moods) {
        final date = DateTime(
          mood.dateTime.year,
          mood.dateTime.month,
          mood.dateTime.day,
        );
        (moodsByDay[date] ??= []).add(mood);
      }
      moodsPerDay = moodsByDay.entries.map((day) {
        final value =
            (day.value.fold(0, (v, m) => v + m.mood.value) / day.value.length)
                .round();
        return Mood(
          dateTime: day.key,
          mood: MoodValue.values.singleWhere((mood) => mood.value == value),
          label: null,
        );
      }).toList();
    }

    data.value = (
      lineChartData: [
        if (moodsPerDay == null)
          ...moods.map(
            (mood) => TimeData(
              domain: mood.dateTime,
              measure: mood.mood.value,
            ),
          )
        else
          ...moodsPerDay.map(
            (mood) => TimeData(
              domain: mood.dateTime,
              measure: mood.mood.value,
            ),
          ),
      ],
      moods: moods,
    );
  }

  Future<void> deleteMood(BuildContext context, Mood mood) async {
    await appState.deleteMood(mood.databaseId!);
    calcLineChartData();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.entryDeleted),
        action: SnackBarAction(
          label: context.l10n.undo,
          onPressed: () async {
            await appState.addMood(mood);
            calcLineChartData();
          },
        ),
      ),
    );
  }

  void onTimeRangeChanged(Set<TimeRange> newTimeRange) {
    timeRange.value = newTimeRange.single;
    calcLineChartData();
  }
}

enum TimeRange { today, week, month, year }
