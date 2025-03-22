import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_planner/models/task.dart';
import 'package:task_planner/providers/task_provider.dart';
import 'package:intl/intl.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            ref.read(taskProvider.notifier).toggleTaskCompletion(task.id);
          },
        ),
        title: Text(
          task.name,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) Text(task.description!),
            Text(
              'Due: ${DateFormat('MMM d, y HH:mm').format(task.dueDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (task.isRepeatable) ...[
              Text(
                'Repeat: ${_getRepeatDaysText(task.repeatDays)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (task.repeatEndDate != null)
                Text(
                  'Ends: ${DateFormat('MMM d, y').format(task.repeatEndDate!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Navigate to edit task screen
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref.read(taskProvider.notifier).deleteTask(task.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getRepeatDaysText(List<bool> repeatDays) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDays = repeatDays
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => days[entry.key])
        .join(', ');
    return selectedDays.isEmpty ? 'Never' : selectedDays;
  }
}
