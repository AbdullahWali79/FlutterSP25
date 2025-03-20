import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

enum QuizDifficulty { easy, medium, hard }

enum QuizMode { practice, timed, challenge }

enum QuizFormat { multipleChoice, trueFalse, mixed }

class Achievement {
  final String title;
  final String description;
  final int requiredScore;
  final IconData icon;
  final String id;

  const Achievement({
    required this.title,
    required this.description,
    required this.requiredScore,
    required this.icon,
    required this.id,
  });
}

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
  bool _isQuizTimerEnabled = false;
  int _quizTimerDuration = 5;
  QuizDifficulty _quizDifficulty = QuizDifficulty.medium;
  QuizMode _quizMode = QuizMode.timed;
  Set<String> _unlockedAchievements = {};
  int _hintsRemaining = 3;
  int _highScore = 0;
  int _longestStreak = 0;
  QuizFormat _quizFormat = QuizFormat.mixed;

  final List<Achievement> achievements = [
    Achievement(
      id: 'perfect_score',
      title: 'Perfect Score',
      description: 'Get all questions correct in a quiz',
      requiredScore: 10,
      icon: Icons.star,
    ),
    Achievement(
      id: 'speed_master',
      title: 'Speed Master',
      description:
          'Complete a timed quiz with less than 3 seconds per question average',
      requiredScore: 8,
      icon: Icons.speed,
    ),
    Achievement(
      id: 'streak_master',
      title: 'Streak Master',
      description: 'Achieve a streak of 5 correct answers',
      requiredScore: 5,
      icon: Icons.local_fire_department,
    ),
    Achievement(
      id: 'practice_makes_perfect',
      title: 'Practice Makes Perfect',
      description: 'Complete 5 practice mode quizzes',
      requiredScore: 5,
      icon: Icons.school,
    ),
  ];

  final Map<QuizDifficulty, Map<String, dynamic>> difficultySettings = {
    QuizDifficulty.easy: {
      'timer': 10,
      'questions': 5,
      'multipleChoice': true,
      'hintsAllowed': true,
    },
    QuizDifficulty.medium: {
      'timer': 7,
      'questions': 10,
      'multipleChoice': true,
      'hintsAllowed': true,
    },
    QuizDifficulty.hard: {
      'timer': 5,
      'questions': 15,
      'multipleChoice': false,
      'hintsAllowed': false,
    },
  };

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
  bool get isQuizTimerEnabled => _isQuizTimerEnabled;
  int get quizTimerDuration => _quizTimerDuration;
  QuizDifficulty get quizDifficulty => _quizDifficulty;
  QuizMode get quizMode => _quizMode;
  Set<String> get unlockedAchievements => _unlockedAchievements;
  int get hintsRemaining => _hintsRemaining;
  int get highScore => _highScore;
  int get longestStreak => _longestStreak;
  QuizFormat get quizFormat => _quizFormat;

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
    _isQuizTimerEnabled = _prefs.getBool('isQuizTimerEnabled') ?? false;
    _quizTimerDuration = _prefs.getInt('quizTimerDuration') ?? 5;
    _quizDifficulty =
        QuizDifficulty.values[_prefs.getInt('quizDifficulty') ?? 1];
    _quizMode = QuizMode.values[_prefs.getInt('quizMode') ?? 1];
    _unlockedAchievements =
        _prefs.getStringList('unlockedAchievements')?.toSet() ?? {};
    _hintsRemaining = _prefs.getInt('hintsRemaining') ?? 3;
    _highScore = _prefs.getInt('highScore') ?? 0;
    _longestStreak = _prefs.getInt('longestStreak') ?? 0;
    _quizFormat = QuizFormat.values[_prefs.getInt('quizFormat') ?? 2];
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

  Future<void> updateQuizTimerEnabled(bool value) async {
    _isQuizTimerEnabled = value;
    await _prefs.setBool('isQuizTimerEnabled', value);
    notifyListeners();
  }

  Future<void> updateQuizTimerDuration(int seconds) async {
    _quizTimerDuration = seconds;
    await _prefs.setInt('quizTimerDuration', seconds);
    notifyListeners();
  }

  Future<void> updateQuizDifficulty(QuizDifficulty difficulty) async {
    _quizDifficulty = difficulty;
    await _prefs.setInt('quizDifficulty', difficulty.index);
    _quizTimerDuration = difficultySettings[difficulty]!['timer'];
    await _prefs.setInt('quizTimerDuration', _quizTimerDuration);
    notifyListeners();
  }

  Future<void> updateQuizMode(QuizMode mode) async {
    _quizMode = mode;
    await _prefs.setInt('quizMode', mode.index);
    notifyListeners();
  }

  Future<void> updateQuizFormat(QuizFormat format) async {
    _quizFormat = format;
    await _prefs.setInt('quizFormat', format.index);
    notifyListeners();
  }

  Future<void> unlockAchievement(String achievementId) async {
    if (!_unlockedAchievements.contains(achievementId)) {
      _unlockedAchievements.add(achievementId);
      await _prefs.setStringList(
          'unlockedAchievements', _unlockedAchievements.toList());
      notifyListeners();
    }
  }

  Future<void> updateHintsRemaining(int hints) async {
    _hintsRemaining = hints;
    await _prefs.setInt('hintsRemaining', hints);
    notifyListeners();
  }

  Future<void> updateHighScore(int score) async {
    if (score > _highScore) {
      _highScore = score;
      await _prefs.setInt('highScore', score);
      notifyListeners();
    }
  }

  Future<void> updateLongestStreak(int streak) async {
    if (streak > _longestStreak) {
      _longestStreak = streak;
      await _prefs.setInt('longestStreak', streak);
      notifyListeners();
    }
  }

  void resetHints() {
    _hintsRemaining = 3;
    _prefs.setInt('hintsRemaining', 3);
    notifyListeners();
  }
}
