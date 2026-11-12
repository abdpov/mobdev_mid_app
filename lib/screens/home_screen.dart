import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import 'widgets/add_todo_sheet.dart';
import 'widgets/todo_item_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAddTodoDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddTodoSheet(
        onAdd: (title) {
          context.read<TodoBloc>().add(AddTodoEvent(title));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Задача добавлена на сервер'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Менеджер задач',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Сервер: dummyjson.com/todos',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить с сервера',
            onPressed: () {
              context.read<TodoBloc>().add(LoadTodosEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoadingState) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Загрузка задач с сервера...'),
                ],
              ),
            );
          }

          if (state is TodoErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        context.read<TodoBloc>().add(LoadTodosEvent());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Попробовать снова'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is TodoLoadedState) {
            return Column(
              children: [
                _buildProgressCard(context, state),
                _buildFilterChips(context, state),
                const SizedBox(height: 8),
                Expanded(
                  child: state.filteredTodos.isEmpty
                      ? _buildEmptyState(state.filter)
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<TodoBloc>().add(LoadTodosEvent());
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: state.filteredTodos.length,
                            itemBuilder: (context, index) {
                              final todo = state.filteredTodos[index];
                              return TodoItemTile(
                                todo: todo,
                                onToggle: (_) {
                                  context
                                      .read<TodoBloc>()
                                      .add(ToggleTodoEvent(todo));
                                },
                                onDelete: () {
                                  context
                                      .read<TodoBloc>()
                                      .add(DeleteTodoEvent(todo.id));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Задача удалена'),
                                      duration: const Duration(seconds: 2),
                                      action: SnackBarAction(
                                        label: 'ОК',
                                        onPressed: () {},
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTodoDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Новая задача'),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, TodoLoadedState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Прогресс выполнения',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                '${state.completedCount} / ${state.totalCount}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.progressPercentage,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, TodoLoadedState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _filterChip(
            context,
            title: 'Все (${state.totalCount})',
            isSelected: state.filter == TodoFilter.all,
            onSelected: () {
              context
                  .read<TodoBloc>()
                  .add(ChangeFilterEvent(TodoFilter.all));
            },
          ),
          const SizedBox(width: 8),
          _filterChip(
            context,
            title: 'Активные (${state.activeCount})',
            isSelected: state.filter == TodoFilter.active,
            onSelected: () {
              context
                  .read<TodoBloc>()
                  .add(ChangeFilterEvent(TodoFilter.active));
            },
          ),
          const SizedBox(width: 8),
          _filterChip(
            context,
            title: 'Готово (${state.completedCount})',
            isSelected: state.filter == TodoFilter.completed,
            onSelected: () {
              context
                  .read<TodoBloc>()
                  .add(ChangeFilterEvent(TodoFilter.completed));
            },
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(title),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildEmptyState(TodoFilter filter) {
    String text = 'Список задач пуст';
    if (filter == TodoFilter.active) {
      text = 'Все задачи выполнены!';
    } else if (filter == TodoFilter.completed) {
      text = 'Пока нет завершенных задач';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            filter == TodoFilter.completed
                ? Icons.done_all_rounded
                : Icons.task_alt_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
