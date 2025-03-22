import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_planner/models/task.dart';
import 'package:task_planner/providers/task_provider.dart';
import 'package:task_planner/widgets/task_card.dart';

class TaskList extends ConsumerWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todaysTasks = tasks.where((task) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      return taskDate.isAtSameMomentAs(today) && !task.isCompleted;
    }).toList();

    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    final repeatableTasks = tasks.where((task) {
      return task.isRepeatable &&
          !task.isCompleted &&
          (task.repeatEndDate == null ||
              task.repeatEndDate!.isAfter(DateTime.now()));
    }).toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'Completed'),
              Tab(text: 'Repeatable'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTaskList(todaysTasks, ref),
                _buildTaskList(completedTasks, ref),
                _buildTaskList(repeatableTasks, ref),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, WidgetRef ref) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No tasks found'),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(task: task);
      },
    );
  }
}
