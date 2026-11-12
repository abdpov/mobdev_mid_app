import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class TodoService {
  static const String baseUrl = 'https://dummyjson.com/todos';

  Future<List<Todo>> fetchTodos({int limit = 20}) async {
    final response = await http.get(Uri.parse('$baseUrl?limit=$limit'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['todos'];
      return list.map((item) => Todo.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tasks from server');
    }
  }

  Future<Todo> addTodo(String title) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'todo': title,
        'completed': false,
        'userId': 1,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Todo.fromJson(data);
    } else {
      throw Exception('Failed to create task on server');
    }
  }

  Future<Todo> updateTodoStatus(int id, bool completed) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'completed': completed,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Todo.fromJson(data);
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<bool> deleteTodo(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }
}
