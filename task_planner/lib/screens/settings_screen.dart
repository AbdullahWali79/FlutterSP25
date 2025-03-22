import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_planner/providers/theme_provider.dart';
import 'package:task_planner/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Theme Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: ref.watch(themeModeProvider) == ThemeMode.dark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          SwitchListTile(
            title: const Text('Enable Gradient Background'),
            value: settings.enableGradientBackground,
            onChanged: (value) {
              ref
                  .read(settingsProvider.notifier)
                  .toggleEnableGradientBackground();
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Task Display',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Show Completed Tasks'),
            value: settings.showCompletedTasks,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleShowCompletedTasks();
            },
          ),
          SwitchListTile(
            title: const Text('Show Repeatable Tasks'),
            value: settings.showRepeatableTasks,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleShowRepeatableTasks();
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Animations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Enable Animations'),
            value: settings.enableAnimations,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleEnableAnimations();
            },
          ),
          if (settings.enableAnimations)
            ListTile(
              title: const Text('Animation Speed'),
              subtitle: Text(settings.animationSpeed),
              trailing: DropdownButton<String>(
                value: settings.animationSpeed,
                items: const [
                  DropdownMenuItem(value: 'Slow', child: Text('Slow')),
                  DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'Fast', child: Text('Fast')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .setAnimationSpeed(value);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
