import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:mood_n_habbits/models/app_state.dart';
import 'package:mood_n_habbits/models/mood.dart';
import 'package:mood_n_habbits/utils/get_l10n.dart';
import 'package:mood_n_habbits/utils/same_day.dart';
import 'package:mood_n_habbits/utils/todos_state_mixin.dart';
import 'package:mood_n_habbits/widgets/adaptive_dialog_button.dart';
import 'package:mood_n_habbits/widgets/adaptive_dialog_textfield.dart';

class TodayPageState with TodosStateMixin {
  TodayPageState(AppState appState) {
    this.appState = appState;
    finishedAtBottom = false;
    onlyActive = true;
    loadTodos();
  }

  final ValueNotifier<DateTime?> date = ValueNotifier(null);

  void addMoodAction(
    BuildContext context,
    MoodValue moodValue,
  ) async {
    final labelInput = await showAdaptiveDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog.adaptive(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(context.l10n.addNote),
          ),
          content: AdaptiveDialogTextField(
            controller: controller,
            placeholder: context.l10n.howIsYourMood,
          ),
          actions: [
            AdaptiveDialogButton(
              onPressed: () => context.pop<String?>(null),
              label: context.l10n.cancel,
            ),
            AdaptiveDialogButton(
              onPressed: () => context.pop<String>(controller.text),
              label: context.l10n.save,
            ),
          ],
        );
      },
    );
    if (labelInput == null) return;
    await appState.addMood(
      Mood(
        mood: moodValue,
        dateTime: date.value ?? DateTime.now(),
        label: labelInput.isEmpty ? null : labelInput,
      ),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.hasBeenSaved(moodValue.emoji)),
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void setActiveDate(DateTime newDate) {
    if (newDate.isSameDay(DateTime.now())) {
      date.value = null;
    } else {
      date.value = newDate;
    }
  }

  void changeDate(BuildContext context) async {
    final oldDate = date.value ?? DateTime.now();

    final newDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(
        const Duration(days: 365 * 100),
      ),
      lastDate: DateTime.now(),
      initialDate: date.value ?? DateTime.now(),
    );
    if (newDate == null) return;
    if (!context.mounted) return;

    date.value = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      oldDate.hour,
      oldDate.minute,
    );
  }

  void changeMoodTime(BuildContext context) async {
    final oldDate = date.value ?? DateTime.now();
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(oldDate),
    );
    if (timeOfDay == null) return;
    if (!context.mounted) return;

    date.value = DateTime(
      oldDate.year,
      oldDate.month,
      oldDate.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }
}
