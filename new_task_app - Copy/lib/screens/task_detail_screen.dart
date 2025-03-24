import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../models/subtask.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  List<Subtask> _subtasks = [];

  @override
  void initState() {
    super.initState();
    _loadSubtasks();
  }

  Future<void> _loadSubtasks() async {
    final subtasks =
        await DatabaseHelper.instance.getSubtasksForTask(widget.task.id!);
    setState(() {
      _subtasks = subtasks.map((subtask) => Subtask.fromMap(subtask)).toList();
    });
  }

  Future<void> _addSubtask() async {
    final titleController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Subtask'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final subtask = Subtask(
                  taskId: widget.task.id!,
                  title: titleController.text,
                );
                await DatabaseHelper.instance.insertSubtask(subtask.toMap());
                Navigator.pop(context);
                _loadSubtasks();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSubtask(Subtask subtask) async {
    await DatabaseHelper.instance.deleteSubtask(subtask.id!);
    _loadSubtasks();
  }

  Future<void> _toggleSubtaskCompletion(Subtask subtask) async {
    subtask.isCompleted = !subtask.isCompleted;
    await DatabaseHelper.instance.updateSubtask(subtask.toMap());
    _loadSubtasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (widget.task.description != null) ...[
                  const SizedBox(height: 8),
                  Text(widget.task.description!),
                ],
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subtask'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _subtasks.length,
              itemBuilder: (context, index) {
                final subtask = _subtasks[index];
                return ListTile(
                  leading: Checkbox(
                    value: subtask.isCompleted,
                    onChanged: (value) => _toggleSubtaskCompletion(subtask),
                  ),
                  title: Text(
                    subtask.title,
                    style: TextStyle(
                      decoration: subtask.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteSubtask(subtask),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
