import '../models/todo.dart';

enum TodoFilter { all, active, completed }

abstract class TodoEvent {}

class LoadTodosEvent extends TodoEvent {}

class AddTodoEvent extends TodoEvent {
  final String title;
  AddTodoEvent(this.title);
}

class ToggleTodoEvent extends TodoEvent {
  final Todo todo;
  ToggleTodoEvent(this.todo);
}

class DeleteTodoEvent extends TodoEvent {
  final int id;
  DeleteTodoEvent(this.id);
}

class ChangeFilterEvent extends TodoEvent {
  final TodoFilter filter;
  ChangeFilterEvent(this.filter);
}
