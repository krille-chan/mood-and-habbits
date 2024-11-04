import 'package:flutter/material.dart';

import 'package:d_chart/d_chart.dart';

import 'package:mood_n_habbits/models/app_state.dart';
import 'package:mood_n_habbits/models/mood.dart';
import 'package:mood_n_habbits/utils/get_l10n.dart';

class MoodStatsState {
  final AppState appState;

  MoodStatsState(this.appState) {
    calcLineChartData();
  }

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

  void calcLineChartData() async {
    final now = DateTime.now();
    final since = switch (timeRange.value) {
      TimeRange.year => DateTime(now.year, 1, 1),
      TimeRange.month => DateTime(now.year, now.month, 1),
      TimeRange.week => DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 7)),
      TimeRange.today => DateTime(now.year, now.month, now.day),
    };

    final moods = await appState.getMoods(since);

    data.value = (
      lineChartData: [
        TimeData(
          domain: now,
          measure: moods.first.mood.value,
        ),
        ...moods.map(
          (mood) => TimeData(
            domain: mood.dateTime,
            measure: mood.mood.value,
          ),
        ),
        TimeData(
          domain: since,
          measure: moods.last.mood.value,
        ),
      ],
      moods: moods
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
