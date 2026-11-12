import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoService todoService;

  TodoBloc({required this.todoService}) : super(TodoInitialState()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<ToggleTodoEvent>(_onToggleTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<ChangeFilterEvent>(_onChangeFilter);
  }

  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    emit(TodoLoadingState());
    try {
      final todos = await todoService.fetchTodos();
      emit(TodoLoadedState(todos: todos));
    } catch (e) {
      emit(TodoErrorState('Не удалось связаться с сервером. Проверьте интернет.'));
    }
  }

  Future<void> _onAddTodo(
    AddTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    final currentState = state;
    if (currentState is TodoLoadedState) {
      try {
        final newTodo = await todoService.addTodo(event.title);
        final updatedList = [newTodo, ...currentState.todos];
        emit(currentState.copyWith(todos: updatedList));
      } catch (e) {
        final localTodo = Todo(
          id: DateTime.now().millisecondsSinceEpoch,
          todo: event.title,
          completed: false,
        );
        emit(currentState.copyWith(todos: [localTodo, ...currentState.todos]));
      }
    }
  }

  Future<void> _onToggleTodo(
    ToggleTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    final currentState = state;
    if (currentState is TodoLoadedState) {
      final updatedStatus = !event.todo.completed;
      final updatedList = currentState.todos.map((item) {
        if (item.id == event.todo.id) {
          return item.copyWith(completed: updatedStatus);
        }
        return item;
      }).toList();

      emit(currentState.copyWith(todos: updatedList));

      try {
        await todoService.updateTodoStatus(event.todo.id, updatedStatus);
      } catch (_) {}
    }
  }

  Future<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    final currentState = state;
    if (currentState is TodoLoadedState) {
      final updatedList =
          currentState.todos.where((item) => item.id != event.id).toList();
      emit(currentState.copyWith(todos: updatedList));

      try {
        await todoService.deleteTodo(event.id);
      } catch (_) {}
    }
  }

  void _onChangeFilter(
    ChangeFilterEvent event,
    Emitter<TodoState> emit,
  ) {
    final currentState = state;
    if (currentState is TodoLoadedState) {
      emit(currentState.copyWith(filter: event.filter));
    }
  }
}
