import '../models/todo.dart';
import 'todo_event.dart';

abstract class TodoState {}

class TodoInitialState extends TodoState {}

class TodoLoadingState extends TodoState {}

class TodoLoadedState extends TodoState {
  final List<Todo> todos;
  final TodoFilter filter;

  TodoLoadedState({
    required this.todos,
    this.filter = TodoFilter.all,
  });

  List<Todo> get filteredTodos {
    switch (filter) {
      case TodoFilter.active:
        return todos.where((t) => !t.completed).toList();
      case TodoFilter.completed:
        return todos.where((t) => t.completed).toList();
      case TodoFilter.all:
        return todos;
    }
  }

  int get totalCount => todos.length;
  int get completedCount => todos.where((t) => t.completed).length;
  int get activeCount => todos.where((t) => !t.completed).length;

  double get progressPercentage =>
      totalCount == 0 ? 0.0 : completedCount / totalCount;

  TodoLoadedState copyWith({
    List<Todo>? todos,
    TodoFilter? filter,
  }) {
    return TodoLoadedState(
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
    );
  }
}

class TodoErrorState extends TodoState {
  final String message;
  TodoErrorState(this.message);
}
