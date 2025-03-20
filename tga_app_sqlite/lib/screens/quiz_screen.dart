import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/settings_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
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

  @override
  void initState() {
    super.initState();
    questions = _generateQuestions();
    _setCurrentQuestion();
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

      List<int> options = [correctAnswer];
      while (options.length < 4) {
        final wrongAnswer = settings.selectedTables[
                random.nextInt(settings.selectedTables.length)] *
            (random.nextInt(settings.tableRangeEnd) + 1);
        if (!options.contains(wrongAnswer)) {
          options.add(wrongAnswer);
        }
      }
      options.shuffle();

      generatedQuestions.add({
        'num1': num1,
        'num2': num2,
        'correctAnswer': correctAnswer,
        'options': options,
        'isMultipleChoice': random.nextBool(),
      });
    }
    return generatedQuestions;
  }

  void _setCurrentQuestion() {
    if (currentQuestion < questions.length) {
      isMultipleChoice = questions[currentQuestion]['isMultipleChoice'];
      correctAnswer = questions[currentQuestion]['correctAnswer'];
      selectedAnswer = null;
      showFeedback = false;
    }
  }

  void _checkAnswer(int? answer) {
    if (answer == null) return;

    setState(() {
      selectedAnswer = answer;
      showFeedback = true;
      if (answer == correctAnswer) {
        score++;
      }

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          if (currentQuestion < totalQuestions - 1) {
            currentQuestion++;
            _setCurrentQuestion();
          } else {
            _saveQuizScore();
            showResult = true;
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
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentQuestion = 0;
                  score = 0;
                  showResult = false;
                  questions = _generateQuestions();
                  _setCurrentQuestion();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: settings.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: settings.fontSize,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
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

    final currentQuestionData = questions[currentQuestion];
    final num1 = currentQuestionData['num1'];
    final num2 = currentQuestionData['num2'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: settings.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentQuestion + 1) / totalQuestions,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(settings.primaryColor),
            ),
            const SizedBox(height: 20),
            Text(
              'Question ${currentQuestion + 1} of $totalQuestions',
              style: TextStyle(fontSize: settings.fontSize),
            ),
            const SizedBox(height: 20),
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
              _buildTrueFalseOptions(
                  currentQuestionData['correctAnswer'], settings),
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
}
