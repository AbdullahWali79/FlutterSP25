import '../models/task.dart';
import 'database_helper.dart';

class TaskService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create a new task
  Future<String> createTask(Task task) async {
    return await _dbHelper.createTask(task);
  }

  // Get all tasks for a user
  Future<List<Task>> getTasks(String userId) async {
    return await _dbHelper.getTasks(userId);
  }

  // Get today's tasks for a user
  Future<List<Task>> getTodayTasks(String userId) async {
    final tasks = await _dbHelper.getTasks(userId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return tasks.where((task) {
      if (task.recurrenceType == RecurrenceType.daily) {
        return true;
      } else if (task.recurrenceType == RecurrenceType.weekly) {
        final dayName = _getDayName(today.weekday);
        return task.selectedDays.contains(dayName);
      } else if (task.recurrenceType == RecurrenceType.monthly) {
        return task.dueDate.day == today.day;
      } else if (task.recurrenceType == RecurrenceType.custom) {
        return task.customDates?.any((date) =>
                date.year == today.year &&
                date.month == today.month &&
                date.day == today.day) ??
            false;
      } else {
        return task.dueDate.year == today.year &&
            task.dueDate.month == today.month &&
            task.dueDate.day == today.day;
      }
    }).toList();
  }

  // Get recurring tasks for a user
  Future<List<Task>> getRecurringTasks(String userId) async {
    final tasks = await _dbHelper.getTasks(userId);
    return tasks
        .where((task) => task.recurrenceType != RecurrenceType.none)
        .toList();
  }

  // Update a task
  Future<void> updateTask(Task task) async {
    await _dbHelper.updateTask(task);
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _dbHelper.deleteTask(taskId);
  }

  // Update task progress
  Future<void> updateTaskProgress(String taskId, double progress) async {
    try {
      final tasks = await _dbHelper.getTasks(taskId);
      final task = tasks.firstWhere((t) => t.id == taskId);
      await _dbHelper.updateTask(task.copyWith(progress: progress));
    } catch (e) {
      rethrow;
    }
  }

  // Get completed tasks for a user
  Future<List<Task>> getCompletedTasks(String userId) async {
    final tasks = await _dbHelper.getTasks(userId);
    return tasks.where((task) => task.status == TaskStatus.completed).toList();
  }

  // Get task statistics
  Future<Map<String, dynamic>> getTaskStatistics(String userId) async {
    final tasks = await _dbHelper.getTodayTasks(userId);
    final totalTasks = tasks.length;
    final completedTasks =
        tasks.where((task) => task.status == TaskStatus.completed).length;

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'completionRate': totalTasks > 0 ? completedTasks / totalTasks : 0,
    };
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}
