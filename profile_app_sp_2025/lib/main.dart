import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const FlashcardScreen(),
    );
  }
}

class Flashcard {
  final String question;
  final String answer;
  final String category;

  const Flashcard(
      {required this.question,
        required this.answer,
        this.category = 'General'});
}

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final List<Flashcard> flashcards = const [
    Flashcard(
      question: "What is the capital of France?",
      answer: "Paris",
      category: "Geography",
    ),
    Flashcard(
      question: "What is 2 + 2?",
      answer: "4",
      category: "Math",
    ),
    Flashcard(
      question: "What is the largest planet in our solar system?",
      answer: "Jupiter",
      category: "Science",
    ),
    Flashcard(
      question: "Who wrote 'Romeo and Juliet'?",
      answer: "William Shakespeare",
      category: "Literature",
    ),
  ];

  int _currentIndex = 0;
  bool _showAnswer = false;

  void _nextCard() {
    setState(() {
      _showAnswer = false;
      _currentIndex = (_currentIndex + 1) % flashcards.length;
    });
  }

  void _previousCard() {
    setState(() {
      _showAnswer = false;
      _currentIndex =
          (_currentIndex - 1 + flashcards.length) % flashcards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _showAnswer = false;
              });
            },
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Card ${_currentIndex + 1} of ${flashcards.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FlashcardWidget(
                flashcard: flashcards[_currentIndex],
                showAnswer: _showAnswer,
                onTap: () {
                  setState(() {
                    _showAnswer = !_showAnswer;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filled(
                  onPressed: _previousCard,
                  icon: const Icon(Icons.arrow_back),
                ),
                IconButton.filled(
                  onPressed: () {
                    setState(() {
                      _showAnswer = !_showAnswer;
                    });
                  },
                  icon: Icon(
                      _showAnswer ? Icons.visibility_off : Icons.visibility),
                ),
                IconButton.filled(
                  onPressed: _nextCard,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FlashcardWidget extends StatelessWidget {
  final Flashcard flashcard;
  final bool showAnswer;
  final VoidCallback onTap;

  const FlashcardWidget({
    super.key,
    required this.flashcard,
    required this.showAnswer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder(
        tween: Tween<double>(
          begin: 0,
          end: showAnswer ? 180 : 0,
        ),
        duration: const Duration(milliseconds: 300),
        builder: (context, double value, child) {
          bool showFront = value < 90;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * math.pi / 180),
            alignment: Alignment.center,
            child: Card(
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform(
                      transform: Matrix4.identity()
                        ..rotateY(showFront ? 0 : math.pi),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            showFront ? flashcard.question : flashcard.answer,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Chip(
                            label: Text(
                              flashcard.category,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            showFront
                                ? 'Tap to reveal answer'
                                : 'Tap to hide answer',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
