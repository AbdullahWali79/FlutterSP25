import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/settings_provider.dart';
import 'dart:async';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  final int totalQuestions = 10;
  int currentQuestion = 0;
  int score = 0;
  late List<Map<String, dynamic>> questions;
  bool showResult = false;
  int? selectedAnswer;
  late int correctAnswer;
  bool isMultipleChoice = true;
  final Random random = Random();
  bool showFeedback = false;
  Timer? _timer;
  int _timeLeft = 0;
  int currentStreak = 0;
  int quizStartTime = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> _nextQuestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    questions = _generateQuestions();
    _preloadNextQuestions();
    _setCurrentQuestion();
    quizStartTime = DateTime.now().millisecondsSinceEpoch;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _generateQuestions() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.selectedTables.isEmpty) {
      return [];
    }

    List<Map<String, dynamic>> generatedQuestions = [];
    for (int i = 0; i < totalQuestions; i++) {
      final num1 = settings
          .selectedTables[random.nextInt(settings.selectedTables.length)];
      final num2 = random.nextInt(settings.tableRangeEnd) + 1;
      final correctAnswer = num1 * num2;

      bool isMultipleChoice = settings.quizFormat == QuizFormat.mixed
          ? random.nextBool()
          : settings.quizFormat == QuizFormat.multipleChoice;

      if (isMultipleChoice) {
        List<int> options = [correctAnswer];
        while (options.length < 4) {
          final wrongAnswer = settings.selectedTables[
                  random.nextInt(settings.selectedTables.length)] *
              (random.nextInt(settings.tableRangeEnd) + 1);
          if (!options.contains(wrongAnswer) && wrongAnswer != correctAnswer) {
            options.add(wrongAnswer);
          }
        }
        options.shuffle();

        generatedQuestions.add({
          'num1': num1,
          'num2': num2,
          'correctAnswer': correctAnswer,
          'options': options,
          'isMultipleChoice': true,
        });
      } else {
        generatedQuestions.add({
          'num1': num1,
          'num2': num2,
          'correctAnswer': correctAnswer,
          'options': [correctAnswer],
          'isMultipleChoice': false,
        });
      }
    }
    return generatedQuestions;
  }

  void _startTimer() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (!settings.isQuizTimerEnabled || settings.quizMode == QuizMode.practice)
      return;

    _timer?.cancel();
    _timeLeft = settings.quizTimerDuration;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          if (_timeLeft <= 3) {
            // TODO: Add tick sound effect
          }
        } else {
          _timer?.cancel();
          if (!showFeedback) {
            // TODO: Add timeout sound
            _checkAnswer(-1);
          }
        }
      });
    });
  }

  void _setCurrentQuestion() {
    if (currentQuestion < questions.length) {
      isMultipleChoice = questions[currentQuestion]['isMultipleChoice'];
      correctAnswer = questions[currentQuestion]['correctAnswer'];
      selectedAnswer = null;
      showFeedback = false;
      _startTimer();
    }
  }

  void _preloadNextQuestions() {
    if (_isLoading || currentQuestion >= totalQuestions - 1) return;
    _isLoading = true;

    _nextQuestions = _generateQuestions().take(3).toList();
    _isLoading = false;
  }

  void _checkAnswer(int? answer) {
    if (answer == null) return;

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      selectedAnswer = answer;
      showFeedback = true;
      if (answer == correctAnswer) {
        score++;
        currentStreak++;
        settings.updateLongestStreak(currentStreak);

        if (currentStreak >= 3) {
          score += (currentStreak ~/ 3);
        }

        if (score == totalQuestions) {
          settings.unlockAchievement('perfect_score');
        }
        if (currentStreak >= 5) {
          settings.unlockAchievement('streak_master');
        }
      } else {
        currentStreak = 0;
      }

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          if (currentQuestion < totalQuestions - 1) {
            currentQuestion++;
            _animationController.reset();
            _setCurrentQuestion();
            _animationController.forward();
            _preloadNextQuestions();
          } else {
            _saveQuizScore();
            showResult = true;

            final quizDuration =
                (DateTime.now().millisecondsSinceEpoch - quizStartTime) ~/ 1000;
            if (settings.quizMode == QuizMode.timed &&
                score >= 8 &&
                quizDuration < totalQuestions * 3) {
              settings.unlockAchievement('speed_master');
            }
          }
        });
      });
    });
  }

  Future<void> _saveQuizScore() async {
    final db = DatabaseHelper();
    await db.insertQuizScore({
      'score': score,
      'total_questions': totalQuestions,
      'quiz_type': 'Mixed',
      'date_taken': DateTime.now().toIso8601String(),
    });
  }

  Widget _buildHintButton(SettingsProvider settings) {
    if (!settings
            .difficultySettings[settings.quizDifficulty]!['hintsAllowed'] ||
        settings.hintsRemaining <= 0) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: const Icon(Icons.lightbulb_outline),
      onPressed: () {
        setState(() {
          if (isMultipleChoice) {
            // Remove two wrong answers
            final options = questions[currentQuestion]['options'] as List<int>;
            options.removeWhere((option) =>
                option != correctAnswer &&
                options.where((o) => o != correctAnswer).length > 2);
          } else {
            _showHintDialog();
          }
          settings.updateHintsRemaining(settings.hintsRemaining - 1);
        });
      },
      tooltip: 'Use Hint (${settings.hintsRemaining} remaining)',
    );
  }

  void _showHintDialog() {
    final num1 = questions[currentQuestion]['num1'];
    final num2 = questions[currentQuestion]['num2'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Multiplication Hint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$num1 × $num2 can be broken down as:'),
            const SizedBox(height: 8),
            Text('$num1 × ${num2 - 1} + $num1'),
            Text('= ${num1 * (num2 - 1)} + $num1'),
            Text('= ${num1 * num2}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(SettingsProvider settings) {
    final currentQuestionData = questions[currentQuestion];
    final num1 = currentQuestionData['num1'];
    final num2 = currentQuestionData['num2'];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.3),
          end: Offset.zero,
        ).animate(_fadeAnimation),
        child: Column(
          children: [
            Text(
              'What is $num1 × $num2?',
              style: TextStyle(
                fontSize: settings.fontSize * 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showFeedback) ...[
              const SizedBox(height: 20),
              Text(
                selectedAnswer == correctAnswer ? 'Correct! 👍' : 'Wrong! 👎',
                style: TextStyle(
                  fontSize: settings.fontSize,
                  color: selectedAnswer == correctAnswer
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$num1 × $num2 = $correctAnswer',
                style: TextStyle(
                  fontSize: settings.fontSize,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 30),
            if (isMultipleChoice)
              ..._buildMultipleChoiceOptions(
                  currentQuestionData['options'], settings)
            else
              _buildTrueFalseOptions(correctAnswer, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerIndicator(SettingsProvider settings) {
    if (!settings.isQuizTimerEnabled ||
        settings.quizMode == QuizMode.practice) {
      return const SizedBox.shrink();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            value: _timeLeft / settings.quizTimerDuration,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _timeLeft <= 3 ? Colors.red : settings.primaryColor,
            ),
            strokeWidth: 4,
          ),
        ),
        Text(
          '$_timeLeft',
          style: TextStyle(
            color: _timeLeft <= 3 ? Colors.red : settings.primaryColor,
            fontSize: settings.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (settings.selectedTables.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          backgroundColor: settings.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Please select at least one table in Settings\nto start the quiz.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    if (showResult) {
      return _buildResultScreen(settings);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            settings.quizMode == QuizMode.practice ? 'Practice Mode' : 'Quiz'),
        backgroundColor: settings.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          _buildHintButton(settings),
          if (settings.quizMode == QuizMode.practice)
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => _showHintDialog(),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${currentQuestion + 1} of $totalQuestions',
                  style: TextStyle(fontSize: settings.fontSize),
                ),
                _buildTimerIndicator(settings),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (currentQuestion + 1) / totalQuestions,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(settings.primaryColor),
            ),
            if (currentStreak >= 3)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orange),
                    Text(' Streak: $currentStreak',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildQuestionContent(settings),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMultipleChoiceOptions(
      List<int> options, SettingsProvider settings) {
    return options.map((option) {
      final bool isSelected = selectedAnswer == option;
      final bool isCorrect = option == correctAnswer;
      Color? buttonColor;
      Color? textColor;

      if (showFeedback) {
        if (option == correctAnswer) {
          buttonColor = Colors.green;
          textColor = Colors.white;
        } else if (isSelected) {
          buttonColor = Colors.red;
          textColor = Colors.white;
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed:
                selectedAnswer == null ? () => _checkAnswer(option) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: textColor,
            ),
            child: Text(
              option.toString(),
              style: TextStyle(fontSize: settings.fontSize),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTrueFalseOptions(int correctAnswer, SettingsProvider settings) {
    final displayedAnswer = random.nextBool()
        ? correctAnswer
        : correctAnswer + random.nextInt(10) + 1;
    final isCorrectAnswer = displayedAnswer == correctAnswer;

    return Column(
      children: [
        Text(
          'Is $displayedAnswer the correct answer?',
          style: TextStyle(fontSize: settings.fontSize),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: selectedAnswer == null
                    ? () => _checkAnswer(isCorrectAnswer ? correctAnswer : -1)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: showFeedback
                      ? (isCorrectAnswer ? Colors.green : Colors.red)
                      : null,
                  foregroundColor: showFeedback ? Colors.white : null,
                ),
                child: Text(
                  'True',
                  style: TextStyle(fontSize: settings.fontSize),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: selectedAnswer == null
                    ? () => _checkAnswer(isCorrectAnswer ? -1 : correctAnswer)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: showFeedback
                      ? (!isCorrectAnswer ? Colors.green : Colors.red)
                      : null,
                  foregroundColor: showFeedback ? Colors.white : null,
                ),
                child: Text(
                  'False',
                  style: TextStyle(fontSize: settings.fontSize),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultScreen(SettingsProvider settings) {
    final percentage = (score / totalQuestions) * 100;
    final Color resultColor = percentage >= 70
        ? Colors.green
        : percentage >= 50
            ? Colors.orange
            : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        backgroundColor: settings.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              percentage >= 70
                  ? Icons.star
                  : percentage >= 50
                      ? Icons.star_half
                      : Icons.star_border,
              size: 100,
              color: resultColor,
            ),
            const SizedBox(height: 20),
            Text(
              'Your Score',
              style: TextStyle(
                fontSize: settings.fontSize * 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$score out of $totalQuestions',
              style: TextStyle(
                fontSize: settings.fontSize * 2,
                fontWeight: FontWeight.bold,
                color: resultColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${percentage.round()}%',
              style: TextStyle(
                fontSize: settings.fontSize * 1.2,
                color: resultColor,
              ),
            ),
            const SizedBox(height: 20),
            if (currentStreak >= 3)
              Text(
                'Final Streak: $currentStreak 🔥',
                style: TextStyle(
                  fontSize: settings.fontSize * 1.2,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      currentQuestion = 0;
                      score = 0;
                      currentStreak = 0;
                      showResult = false;
                      questions = _generateQuestions();
                      _preloadNextQuestions();
                      _setCurrentQuestion();
                      quizStartTime = DateTime.now().millisecondsSinceEpoch;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: settings.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
