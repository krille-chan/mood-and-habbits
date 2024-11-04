import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:mood_n_habbits/models/mood.dart';
import 'package:mood_n_habbits/pages/today/today_page_state.dart';
import 'package:mood_n_habbits/utils/get_l10n.dart';

class TodayPage extends StatelessWidget {
  final TodayPageState state;
  const TodayPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.today),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Material(
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
                        onPressed: () {},
                        child: ValueListenableBuilder(
                          valueListenable: state.newMoodDateTime,
                          builder: (context, dateTime, _) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (dateTime == null)
                                Text(context.l10n.today)
                              else
                                Text(DateFormat.yMd().format(dateTime)),
                              Text(
                                ' ${DateFormat.Hm().format(dateTime ?? DateTime.now())}',
                              ),
                            ],
                          ),
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
                            onPressed: () => state.addMoodAction(context, mood),
                          ),
                        )
                        .toList(),
                  ),
                  TextButton.icon(
                    onPressed: () => context.go('/today/mood_stats'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                    ),
                    label: Text(context.l10n.statistics),
                    icon: const Icon(Icons.calendar_month_outlined),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
