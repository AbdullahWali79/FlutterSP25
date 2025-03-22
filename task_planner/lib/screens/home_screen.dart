import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_planner/providers/task_provider.dart';
import 'package:task_planner/widgets/task_list.dart';
import 'package:task_planner/widgets/add_task_button.dart';
import 'package:task_planner/screens/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: const Column(
        children: [
          AddTaskButton(),
          Expanded(
            child: TaskList(),
          ),
        ],
      ),
    );
  }
}
