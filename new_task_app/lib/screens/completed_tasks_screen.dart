import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';

class CompletedTasksScreen extends StatefulWidget {
  const CompletedTasksScreen({super.key});

  @override
  State<CompletedTasksScreen> createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<CompletedTasksScreen> {
  List<Task> _completedTasks = [];

  @override
  void initState() {
    super.initState();
    _loadCompletedTasks();
  }

  Future<void> _loadCompletedTasks() async {
    final tasks = await DatabaseHelper.instance.getAllTasks();
    setState(() {
      _completedTasks = tasks
          .map((task) => Task.fromMap(task))
          .where((task) => task.isCompleted)
          .toList();
    });
  }

  Future<void> _deleteTask(Task task) async {
    await DatabaseHelper.instance.deleteTask(task.id!);
    _loadCompletedTasks();
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await DatabaseHelper.instance.updateTask(task.toMap());
    _loadCompletedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Tasks'),
      ),
      body: ListView.builder(
        itemCount: _completedTasks.length,
        itemBuilder: (context, index) {
          final task = _completedTasks[index];
          return ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) => _toggleTaskCompletion(task),
            ),
            title: Text(
              task.title,
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
              ),
            ),
            subtitle: task.description != null ? Text(task.description!) : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteTask(task),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/task',
                arguments: task,
              );
            },
          );
        },
      ),
    );
  }
}
