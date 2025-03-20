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
    }
  }

  void _checkAnswer(int? answer) {
    if (answer == null) return;

    setState(() {
      selectedAnswer = answer;
      if (answer == correctAnswer) {
        score++;
      }

      Future.delayed(const Duration(milliseconds: 500), () {
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

      if (isSelected) {
        buttonColor = isCorrect ? Colors.green : Colors.red;
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
              foregroundColor: buttonColor != null ? Colors.white : null,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: settings.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Quiz Complete!',
              style: TextStyle(
                fontSize: settings.fontSize * 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Score: $score out of $totalQuestions',
              style: TextStyle(fontSize: settings.fontSize),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: settings.fontSize * 1.8,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Return to Home',
                style: TextStyle(fontSize: settings.fontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
