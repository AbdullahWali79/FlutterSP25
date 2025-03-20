import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(
    ChangeNotifierProvider.value(
      value: settingsProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Multiplication Mastery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: settings.primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.getFont(
            settings.fontFamily,
            fontSize: settings.fontSize,
          ),
          bodyMedium: GoogleFonts.getFont(
            settings.fontFamily,
            fontSize: settings.fontSize * 0.9,
          ),
        ),
      ),
      home: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  settings.primaryColor.withOpacity(0.1),
                  Colors.white,
                  settings.primaryColor.withOpacity(0.05),
                ],
              ),
            ),
          ),
          const HomeScreen(),
        ],
      ),
    );
  }
}
