import 'package:flutter/material.dart';
import '../../models/todo.dart';

class TodoItemTile extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;

  const TodoItemTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: todo.completed
              ? Colors.transparent
              : Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      color: todo.completed
          ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
          : Theme.of(context).cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: todo.completed,
          onChanged: onToggle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        title: Text(
          todo.todo,
          style: TextStyle(
            fontSize: 15,
            decoration: todo.completed ? TextDecoration.lineThrough : null,
            color: todo.completed
                ? Colors.grey
                : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: todo.completed ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete,
          tooltip: 'Удалить',
        ),
      ),
    );
  }
}
