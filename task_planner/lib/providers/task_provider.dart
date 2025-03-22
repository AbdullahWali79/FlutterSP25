import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_planner/models/task.dart';
import 'package:task_planner/services/database_service.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseService.instance.getAllTasks();
    state = tasks;
  }

  Future<void> addTask(Task task) async {
    await DatabaseService.instance.insertTask(task);
    state = [...state, task];
  }

  Future<void> updateTask(Task task) async {
    await DatabaseService.instance.updateTask(task);
    state = state.map((t) => t.id == task.id ? task : t).toList();
  }

  Future<void> deleteTask(String id) async {
    await DatabaseService.instance.deleteTask(id);
    state = state.where((task) => task.id != id).toList();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = state.firstWhere((t) => t.id == id);
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }
}
