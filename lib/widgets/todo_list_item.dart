import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:mood_n_habits/models/todo.dart';
import 'package:mood_n_habits/utils/get_l10n.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final void Function(bool? done)? toggleDone;
  final void Function()? onEdit;
  final void Function()? onDelete;
  final bool reordering;
  final bool flying;

  const TodoListItem({
    required this.todo,
    this.toggleDone,
    this.onEdit,
    this.onDelete,
    required this.reordering,
    this.flying = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Material(
        elevation: flying ? 4 : 0,
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.0),
        clipBehavior: Clip.hardEdge,
        child: Opacity(
          opacity: todo.finishedAt == null ? 1 : 0.5,
          child: reordering
              ? ListTile(
                  title: _TodoListItemTitle(todo: todo),
                  subtitle: _TodoListItemSubtitle(
                    todo: todo,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
                  trailing: const Icon(Icons.reorder_outlined),
                )
              : CheckboxListTile.adaptive(
                  value: todo.finishedAt != null,
                  onChanged: toggleDone,
                  title: _TodoListItemTitle(todo: todo),
                  subtitle: _TodoListItemSubtitle(
                    todo: todo,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
                ),
        ),
      ),
    );
  }
}

class _TodoListItemSubtitle extends StatelessWidget {
  final Todo todo;
  const _TodoListItemSubtitle({
    required this.todo,
    required this.onEdit,
    required this.onDelete,
  });

  final void Function()? onEdit;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = todo.description;
    final startDate = todo.startDate;
    final dueDate = todo.dueDate;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (description != null) Text(description),
        Wrap(
          children: [
            IconButton(
              style: IconButton.styleFrom(
                shape: CircleBorder(
                  side: BorderSide(
                    color: theme.dividerColor,
                  ),
                ),
              ),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              style: IconButton.styleFrom(
                shape: CircleBorder(
                  side: BorderSide(
                    color: theme.dividerColor,
                  ),
                ),
              ),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.delete_outlined,
                size: 20,
              ),
              onPressed: onDelete,
            ),
            if (startDate != null)
              _DateTile(
                startDate,
                context.l10n.startTime,
                onEdit: onEdit,
              ),
            if (dueDate != null)
              _DateTile(
                dueDate,
                context.l10n.dueTime,
                isLate: DateTime.now().isAfter(dueDate),
                onEdit: onEdit,
              ),
          ],
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isLate;
  final void Function()? onEdit;

  const _DateTile(
    this.date,
    this.label, {
    this.isLate = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: isLate ? theme.colorScheme.errorContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99.0),
          side: BorderSide(
            color: theme.dividerColor,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(99.0),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.5, horizontal: 8.0),
            child: Text(
              '$label: ${DateFormat.yMd(context.l10n.localeName).format(date)}, ${DateFormat.Hm(context.l10n.localeName).format(date)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isLate ? theme.colorScheme.onErrorContainer : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TodoListItemTitle extends StatelessWidget {
  const _TodoListItemTitle({required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Text(
      todo.title,
      style: TextStyle(
        decoration: todo.finishedAt == null ? null : TextDecoration.lineThrough,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
