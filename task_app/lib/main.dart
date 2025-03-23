import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_app/pages/home_page.dart';
import 'package:task_app/pages/settings_page.dart';
import 'package:task_app/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = switch (settings.themeMode) {
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
      ThemeMode.dark => true,
      ThemeMode.light => false,
    };

    return MaterialApp(
      title: 'Task Manager',
      theme: ref.read(settingsProvider.notifier).getTheme(isDark),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
