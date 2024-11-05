import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:d_chart/d_chart.dart';
import 'package:intl/intl.dart';

import 'package:mood_n_habbits/models/mood.dart';
import 'package:mood_n_habbits/pages/mood_stats/mood_stats_state.dart';
import 'package:mood_n_habbits/utils/get_l10n.dart';
import 'package:mood_n_habbits/utils/same_day.dart';

class MoodStatsPage extends StatelessWidget {
  final MoodStatsState state;
  const MoodStatsPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.moodStatistics),
      ),
      body: ValueListenableBuilder(
        valueListenable: state.data,
        builder: (context, data, _) {
          final moods = data.moods;
          final lineChartData = data.lineChartData;
          if (moods == null || moods.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.query_stats_outlined,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.notEnoughDataYet,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SegmentedButton<TimeRange>(
                  segments: TimeRange.values
                      .map(
                        (range) => ButtonSegment<TimeRange>(
                          value: range,
                          label: Text(
                            switch (range) {
                              TimeRange.year => context.l10n.year,
                              TimeRange.month => context.l10n.month,
                              TimeRange.week => context.l10n.week,
                              TimeRange.today => context.l10n.day,
                            },
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      )
                      .toList(),
                  selected: {state.timeRange.value},
                  onSelectionChanged: state.onTimeRangeChanged,
                ),
              ),
              if (lineChartData != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 256,
                    child: DChartLineT(
                      layoutMargin: LayoutMargin(30, 10, 30, 10),
                      domainAxis: DomainAxis(
                        showLine: true,
                        tickLength: 0,
                        tickLabelFormatterT: (domain) {
                          final format = switch (state.timeRange.value) {
                            TimeRange.year => DateFormat.MMM(),
                            TimeRange.month => DateFormat.Md(),
                            TimeRange.week => DateFormat.E(),
                            TimeRange.today => DateFormat.Hm(),
                          };
                          return format.format(domain);
                        },
                      ),
                      measureAxis: MeasureAxis(
                        numericTickProvider:
                            const NumericTickProvider(desiredTickCount: 6),
                        tickLabelFormatter: (i) =>
                            MoodValue.values
                                .singleWhereOrNull((mood) => mood.value == i)
                                ?.emoji ??
                            ' ',
                        labelStyle: const LabelStyle(fontSize: 18),
                        useGridLine: true,
                        gridLineStyle: const LineStyle(dashPattern: [5]),
                      ),
                      groupList: [
                        TimeGroup(
                          color: theme.colorScheme.tertiary,
                          id: '1',
                          data: lineChartData,
                        ),
                      ],
                    ),
                  ),
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: moods.length,
                itemBuilder: (context, i) {
                  final mood = moods[i];

                  final displayDate =
                      i == 0 || !mood.dateTime.isSameDay(moods[i - 1].dateTime);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (displayDate)
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                DateFormat.yMMMEd().format(mood.dateTime),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                      Dismissible(
                        key: ValueKey(moods[i].databaseId ?? i),
                        background: Material(
                          color: theme.colorScheme.errorContainer,
                          child: const Icon(Icons.delete_outlined),
                        ),
                        onDismissed: (_) => state.deleteMood(context, moods[i]),
                        child: ListTile(
                          leading: Text(
                            moods[i].mood.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          title:
                              Text(DateFormat.Hm().format(moods[i].dateTime)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
