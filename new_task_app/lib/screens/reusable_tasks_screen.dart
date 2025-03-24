import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';

class ReusableTasksScreen extends StatefulWidget {
  const ReusableTasksScreen({super.key});

  @override
  State<ReusableTasksScreen> createState() => _ReusableTasksScreenState();
}

class _ReusableTasksScreenState extends State<ReusableTasksScreen> {
  List<Task> _reusableTasks = [];

  @override
  void initState() {
    super.initState();
    _loadReusableTasks();
  }

  Future<void> _loadReusableTasks() async {
    final tasks = await DatabaseHelper.instance.getAllTasks();
    setState(() {
      _reusableTasks = tasks
          .map((task) => Task.fromMap(task))
          .where((task) => task.isRepeatable)
          .toList();
    });
  }

  Future<void> _reuseTask(Task task) async {
    final newTask = Task(
      title: task.title,
      description: task.description,
      createdAt: DateTime.now(),
      isRepeatable: false,
      isCompleted: false,
    );
    await DatabaseHelper.instance.insertTask(newTask.toMap());
  }

  Future<void> _reuseAllTasks() async {
    for (var task in _reusableTasks) {
      await _reuseTask(task);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All tasks have been reused'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteTask(Task task) async {
    await DatabaseHelper.instance.deleteTask(task.id!);
    _loadReusableTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reusable Tasks'),
        actions: [
          if (_reusableTasks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reuse All Tasks',
              onPressed: _reuseAllTasks,
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: _reusableTasks.length,
        itemBuilder: (context, index) {
          final task = _reusableTasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Row(
              children: [
                if (task.description != null)
                  Expanded(child: Text(task.description!)),
                if (task.isCompleted) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Colors.green),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _reuseTask(task),
                  tooltip: 'Reuse Task',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteTask(task),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
