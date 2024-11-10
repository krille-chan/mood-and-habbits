import 'package:flutter/material.dart';

import 'package:mood_n_habbits/models/todo.dart';

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
        Row(
          children: [
            if (startDate != null) Text(startDate.toString()),
            if (dueDate != null) Text(dueDate.toString()),
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
          ],
        ),
      ],
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
      ),
    );
  }
}
