import 'package:flutter/material.dart';

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

  const Flashcard({required this.question, required this.answer});
}

class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({super.key});

  static final List<Flashcard> flashcards = [
    const Flashcard(
      question: "What is the capital of France?",
      answer: "Paris",
    ),
    const Flashcard(
      question: "What is 2 + 2?",
      answer: "4",
    ),
    const Flashcard(
      question: "What is the largest planet in our solar system?",
      answer: "Jupiter",
    ),
    const Flashcard(
      question: "Who wrote 'Romeo and Juliet'?",
      answer: "William Shakespeare",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: FlashcardWidget(flashcard: flashcards[index]),
          );
        },
      ),
    );
  }
}

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardWidget({
    super.key,
    required this.flashcard,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool _showAnswer = false;

  void _toggleCard() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: Card(
        elevation: 4,
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _showAnswer
                    ? widget.flashcard.answer
                    : widget.flashcard.question,
                key: ValueKey<bool>(_showAnswer),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
