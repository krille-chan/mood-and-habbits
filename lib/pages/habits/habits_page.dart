import 'package:flutter/material.dart';

import 'package:mood_n_habits/pages/habits/habits_page_state.dart';
import 'package:mood_n_habits/utils/get_l10n.dart';
import 'package:mood_n_habits/widgets/habit_list_item.dart';

class HabitsPage extends StatelessWidget {
  final HabitsPageState state;
  const HabitsPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder(
      valueListenable: state.habits,
      builder: (context, habits, _) => ValueListenableBuilder<bool>(
        valueListenable: state.reordering,
        builder: (context, reordering, _) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(context.l10n.habits),
              centerTitle: false,
              actions: habits == null || habits.isEmpty
                  ? null
                  : [
                      IconButton(
                        icon: Icon(
                          reordering
                              ? Icons.cancel_outlined
                              : Icons.sort_outlined,
                        ),
                        onPressed: state.toggleReordering,
                      ),
                    ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => state.createHabit(context),
              label: Text(context.l10n.habit),
              icon: const Icon(Icons.add_outlined),
            ),
            body: habits == null
                ? const Center(child: CircularProgressIndicator.adaptive())
                : habits.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.sports_score_outlined,
                          size: 128,
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                      )
                    : reordering
                        ? ReorderableListView.builder(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            itemCount: habits.length,
                            itemBuilder: (context, i) => HabitListItem(
                              reordering: reordering,
                              key: ValueKey(habits[i].habit.databaseId),
                              habit: habits[i].habit,
                              achieved: habits[i].achieved,
                              onSetAchieved: (value, date) => state.setAchieved(
                                context,
                                habits[i].habit,
                                value,
                                date,
                              ),
                            ),
                            proxyDecorator: (child, i, __) => HabitListItem(
                              reordering: reordering,
                              key: ValueKey(habits[i].habit.databaseId),
                              habit: habits[i].habit,
                              flying: true,
                              achieved: habits[i].achieved,
                              onSetAchieved: (value, date) => state.setAchieved(
                                context,
                                habits[i].habit,
                                value,
                                date,
                              ),
                            ),
                            onReorder: state.onReorder,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 16.0,
                              right: 16.0,
                              bottom: 64.0,
                            ),
                            itemCount: habits.length,
                            itemBuilder: (context, i) => HabitListItem(
                              reordering: reordering,
                              habit: habits[i].habit,
                              settings: (
                                onEdit: () =>
                                    state.editHabit(context, habits[i].habit),
                                onDelete: () => state
                                    .deleteHabit(habits[i].habit.databaseId!),
                              ),
                              achieved: habits[i].achieved,
                              onSetAchieved: (value, date) => state.setAchieved(
                                context,
                                habits[i].habit,
                                value,
                                date,
                              ),
                            ),
                          ),
          );
        },
      ),
    );
  }
}
