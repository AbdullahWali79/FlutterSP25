import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_planner/screens/home_screen.dart';
import 'package:task_planner/theme/app_theme.dart';
import 'package:task_planner/providers/theme_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TaskPlannerApp(),
    ),
  );
}

class TaskPlannerApp extends ConsumerWidget {
  const TaskPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Task Planner',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
