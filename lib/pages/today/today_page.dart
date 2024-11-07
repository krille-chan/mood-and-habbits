import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:mood_n_habbits/models/mood.dart';
import 'package:mood_n_habbits/pages/today/today_page_state.dart';
import 'package:mood_n_habbits/utils/get_l10n.dart';
import 'package:mood_n_habbits/utils/same_day.dart';

class TodayPage extends StatelessWidget {
  final TodayPageState state;
  const TodayPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder(
      valueListenable: state.date,
      builder: (context, date, _) {
        final activeDate = date ?? DateTime.now();
        final now = DateTime.now();
        return Scaffold(
          body: SafeArea(
            child: ListView(
              children: [
                SizedBox(
                  height: 103,
                  child: ListView.builder(
                    reverse: true,
                    itemCount: 15,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      if (i == 14) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.secondaryContainer,
                                foregroundColor:
                                    theme.colorScheme.onSecondaryContainer,
                              ),
                              icon: const Icon(Icons.calendar_month_outlined),
                              onPressed: () => state.changeDate(context),
                            ),
                          ),
                        );
                      }
                      final tileDate = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        activeDate.hour,
                        activeDate.minute,
                      ).subtract(Duration(days: i));
                      final isActiveDate = tileDate.isSameDay(activeDate);
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 8.0,
                        ),
                        width: 48,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: isActiveDate
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isActiveDate
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondaryContainer,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => state.setActiveDate(tileDate),
                          borderRadius: BorderRadius.circular(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    tileDate.day.toString(),
                                    style: TextStyle(
                                      color: isActiveDate
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme
                                              .colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                color: isActiveDate
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.secondary,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      DateFormat.E().format(tileDate),
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: isActiveDate
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme.onSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.l10n.howIsYourMood,
                                  style: theme.textTheme.labelLarge,
                                ),
                              ),
                              TextButton(
                                onPressed: () => state.changeMoodTime(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (date == null ||
                                        date.isSameDay(DateTime.now()))
                                      Text(context.l10n.today)
                                    else
                                      Text(DateFormat.yMd().format(date)),
                                    if (date != null)
                                      Text(
                                        ' ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date))}',
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: MoodValue.values
                                .map(
                                  (mood) => IconButton(
                                    icon: Text(
                                      mood.emoji,
                                      style: theme.textTheme.headlineLarge,
                                    ),
                                    onPressed: () =>
                                        state.addMoodAction(context, mood),
                                  ),
                                )
                                .toList(),
                          ),
                          TextButton.icon(
                            onPressed: () => context.go('/today/mood_stats'),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  theme.colorScheme.onSecondaryContainer,
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                            ),
                            label: Text(context.l10n.statistics),
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
