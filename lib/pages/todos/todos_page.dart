import 'package:flutter/material.dart';

import 'package:mood_n_habbits/pages/todos/todos_page_state.dart';
import 'package:mood_n_habbits/utils/get_l10n.dart';

class TodosPage extends StatelessWidget {
  final TodosPageState state;
  const TodosPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder(
      valueListenable: state.data,
      builder: (context, data, _) {
        final todos = data.todos;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Todos'),
            actions: todos == null || todos.isEmpty
                ? null
                : [
                    IconButton(
                      icon: const Icon(Icons.cleaning_services_outlined),
                      onPressed: state.clearFinished,
                    ),
                    IconButton(
                      icon: Icon(
                        data.reordering
                            ? Icons.cancel_outlined
                            : Icons.sort_outlined,
                      ),
                      onPressed: state.toggleReordering,
                    ),
                  ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => state.createTodo(context),
            label: Text(context.l10n.todo),
            icon: const Icon(Icons.add_outlined),
          ),
          body: todos == null
              ? const Center(child: CircularProgressIndicator.adaptive())
              : todos.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.done_all_outlined,
                        size: 128,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: todos.length,
                      itemBuilder: (context, i) {
                        final todo = todos[i];
                        final description = todo.description;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Material(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16.0),
                            clipBehavior: Clip.hardEdge,
                            child: Opacity(
                              opacity: todo.finishedAt == null ? 1 : 0.5,
                              child: CheckboxListTile.adaptive(
                                value: todo.finishedAt != null,
                                onChanged: (finished) => state.toggleDone(
                                  todo,
                                  finished == true,
                                ),
                                title: Text(
                                  todo.title,
                                  style: TextStyle(
                                    decoration: todo.finishedAt == null
                                        ? null
                                        : TextDecoration.lineThrough,
                                  ),
                                ),
                                subtitle: description == null
                                    ? null
                                    : Text(description),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
