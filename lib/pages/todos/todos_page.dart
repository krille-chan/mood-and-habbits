import 'package:flutter/material.dart';

import 'package:mood_n_habbits/models/todo.dart';
import 'package:mood_n_habbits/pages/todos/todo_list_item.dart';
import 'package:mood_n_habbits/pages/todos/todos_page_state.dart';
import 'package:mood_n_habbits/utils/get_l10n.dart';

class TodosPage extends StatelessWidget {
  final TodosPageState state;
  const TodosPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<List<Todo>?>(
      valueListenable: state.todos,
      builder: (context, todos, _) => ValueListenableBuilder<bool>(
        valueListenable: state.reordering,
        builder: (context, reordering, _) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(context.l10n.oneTimeTodos),
              centerTitle: false,
              actions: todos == null || todos.isEmpty
                  ? null
                  : [
                      if (!reordering)
                        IconButton(
                          icon: const Icon(Icons.cleaning_services_outlined),
                          onPressed: state.clearFinished,
                        ),
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
                    : reordering
                        ? ReorderableListView.builder(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            itemCount: todos.length,
                            itemBuilder: (context, i) => TodoListItem(
                              reordering: reordering,
                              key: ValueKey(todos[i].databaseId),
                              todo: todos[i],
                            ),
                            proxyDecorator: (child, i, __) => TodoListItem(
                              reordering: reordering,
                              key: ValueKey(todos[i].databaseId),
                              todo: todos[i],
                              flying: true,
                            ),
                            onReorder: state.onReorder,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            itemCount: todos.length,
                            itemBuilder: (context, i) => TodoListItem(
                              reordering: reordering,
                              todo: todos[i],
                              toggleDone: (b) => state.toggleDone(
                                todos[i],
                                b == true,
                              ),
                              onEdit: () => state.editTodo(context, todos[i]),
                              onDelete: () =>
                                  state.deleteTodo(todos[i].databaseId!),
                            ),
                          ),
          );
        },
      ),
    );
  }
}
