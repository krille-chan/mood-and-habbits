import 'package:flutter/material.dart';

import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:mood_n_habbits/models/mood.dart';
import 'package:mood_n_habbits/models/todo.dart';
import 'package:mood_n_habbits/pages/today/today_page_state.dart';
import 'package:mood_n_habbits/utils/get_l10n.dart';
import 'package:mood_n_habbits/utils/same_day.dart';
import 'package:mood_n_habbits/widgets/todo_list_item.dart';

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
          appBar: AppBar(
            title: Text(
              activeDate.isSameDay(now)
                  ? context.l10n.today
                  : DateFormat.yMEd(context.l10n.localeName).format(activeDate),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: () => state.changeDate(context),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              children: [
                SizedBox(
                  height: 103,
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
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
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: isActiveDate
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: InkWell(
                          onTap: () => state.setActiveDate(tileDate),
                          borderRadius: BorderRadius.circular(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    DateFormat.E(context.l10n.localeName)
                                        .format(tileDate),
                                    style: TextStyle(
                                      color: isActiveDate
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onSurface,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                color: isActiveDate
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(16.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      tileDate.day.toString(),
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: isActiveDate
                                            ? theme.colorScheme.onPrimary
                                            : theme
                                                .colorScheme.onPrimaryContainer,
                                        fontSize: 15,
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
                    borderRadius: BorderRadius.circular(16.0),
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
                                      Text(
                                        DateFormat.yMd(
                                          context.l10n.localeName,
                                        ).format(date),
                                      ),
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
                ValueListenableBuilder<List<Todo>?>(
                  valueListenable: state.todos,
                  builder: (context, todos, _) {
                    if (todos == null) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: todos.length,
                      itemBuilder: (context, i) => TodoListItem(
                        todo: todos[i],
                        reordering: false,
                        toggleDone: (done) => state.toggleDone(
                          todos[i],
                          done == true,
                        ),
                        onEdit: () => state.editTodo(context, todos[i]),
                        onDelete: () => state.deleteTodo(todos[i].databaseId!),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton: ExpandableFab(
            openButtonBuilder: RotateFloatingActionButtonBuilder(
              child: const Icon(Icons.add_outlined),
            ),
            closeButtonBuilder: DefaultFloatingActionButtonBuilder(
              child: const Icon(Icons.close_outlined),
            ),
            type: ExpandableFabType.fan,
            distance: 70,
            children: [
              FloatingActionButton.extended(
                heroTag: null,
                onPressed: null,
                icon: const Icon(Icons.sports_score_outlined),
                label: Text(context.l10n.habbit),
              ),
              FloatingActionButton.extended(
                heroTag: null,
                onPressed: () => state.createTodo(context),
                icon: const Icon(Icons.check_circle_outlined),
                label: Text(context.l10n.todo),
              ),
            ],
          ),
        );
      },
    );
  }
}
