import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeColors {
  final Color primary;
  final Color secondary;
  final List<Color> gradient;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.gradient,
  });
}

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  int _tableRangeStart = 1;
  int _tableRangeEnd = 20;
  double _fontSize = 20;
  String _fontFamily = 'Open Sans';
  int _selectedThemeIndex = 0;
  List<int> _selectedTables = List.generate(20, (index) => index + 1);

  final List<ThemeColors> themeOptions = [
    ThemeColors(
      primary: Colors.blue,
      secondary: Colors.lightBlue,
      gradient: [Colors.blue.shade300, Colors.blue.shade700],
    ),
    ThemeColors(
      primary: Colors.purple,
      secondary: Colors.purpleAccent,
      gradient: [Colors.purple.shade300, Colors.purple.shade700],
    ),
    ThemeColors(
      primary: Colors.pink,
      secondary: Colors.pinkAccent,
      gradient: [Colors.pink.shade300, Colors.pink.shade700],
    ),
    ThemeColors(
      primary: Colors.green,
      secondary: Colors.lightGreen,
      gradient: [Colors.green.shade300, Colors.green.shade700],
    ),
    ThemeColors(
      primary: Colors.orange,
      secondary: Colors.deepOrange,
      gradient: [Colors.orange.shade300, Colors.orange.shade700],
    ),
    ThemeColors(
      primary: Colors.teal,
      secondary: Colors.tealAccent,
      gradient: [Colors.teal.shade300, Colors.teal.shade700],
    ),
  ];

  int get tableRangeStart => _tableRangeStart;
  int get tableRangeEnd => _tableRangeEnd;
  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  Color get primaryColor => themeOptions[_selectedThemeIndex].primary;
  Color get secondaryColor => themeOptions[_selectedThemeIndex].secondary;
  List<Color> get gradientColors => themeOptions[_selectedThemeIndex].gradient;
  int get selectedThemeIndex => _selectedThemeIndex;
  List<int> get selectedTables => _selectedTables;

  TextTheme get textTheme {
    final baseStyle = GoogleFonts.getFont(
      _fontFamily,
      textStyle: TextStyle(fontSize: _fontSize),
    );
    return TextTheme(
      bodyLarge: baseStyle,
      bodyMedium: baseStyle,
      titleLarge: baseStyle.copyWith(fontSize: _fontSize * 1.2),
      titleMedium: baseStyle,
      labelLarge: baseStyle,
    );
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    _tableRangeStart = _prefs.getInt('tableRangeStart') ?? 1;
    _tableRangeEnd = _prefs.getInt('tableRangeEnd') ?? 20;
    _fontSize = _prefs.getDouble('fontSize') ?? 20;
    _fontFamily = _prefs.getString('fontFamily') ?? 'Open Sans';
    _selectedThemeIndex = _prefs.getInt('selectedThemeIndex') ?? 0;
    _selectedTables =
        _prefs.getStringList('selectedTables')?.map(int.parse).toList() ??
            List.generate(20, (index) => index + 1);
    notifyListeners();
  }

  Future<void> updateTableRangeStart(int value) async {
    _tableRangeStart = value;
    await _prefs.setInt('tableRangeStart', value);
    notifyListeners();
  }

  Future<void> updateTableRangeEnd(int value) async {
    _tableRangeEnd = value;
    await _prefs.setInt('tableRangeEnd', value);
    notifyListeners();
  }

  Future<void> updateFontSize(double value) async {
    _fontSize = value;
    await _prefs.setDouble('fontSize', value);
    notifyListeners();
  }

  Future<void> updateFontFamily(String value) async {
    _fontFamily = value;
    await _prefs.setString('fontFamily', value);
    notifyListeners();
  }

  Future<void> updateTheme(int index) async {
    _selectedThemeIndex = index;
    await _prefs.setInt('selectedThemeIndex', index);
    notifyListeners();
  }

  Future<void> updateSelectedTables(List<int> value) async {
    _selectedTables = value;
    await _prefs.setStringList(
        'selectedTables', value.map((e) => e.toString()).toList());
    notifyListeners();
  }
}
