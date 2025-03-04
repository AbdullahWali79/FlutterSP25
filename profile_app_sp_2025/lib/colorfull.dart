// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const FlashcardApp());
// }
//
// class FlashcardApp extends StatelessWidget {
//   const FlashcardApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // A lively theme with a custom color scheme and Material 3 enabled
//     return MaterialApp(
//       title: 'Colorful Flashcards',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
//         useMaterial3: true,
//         textTheme: const TextTheme(
//           headlineSmall: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.deepPurple,
//           ),
//         ),
//       ),
//       home: const FlashcardScreen(),
//     );
//   }
// }
//
// class Flashcard {
//   final String question;
//   final String answer;
//
//   const Flashcard({
//     required this.question,
//     required this.answer,
//   });
// }
//
// class FlashcardScreen extends StatelessWidget {
//   const FlashcardScreen({Key? key}) : super(key: key);
//
//   static final List<Flashcard> flashcards = [
//     const Flashcard(
//       question: "What is the capital of France?",
//       answer: "Paris",
//     ),
//     const Flashcard(
//       question: "What is 2 + 2?",
//       answer: "4",
//     ),
//     const Flashcard(
//       question: "What is the largest planet in our solar system?",
//       answer: "Jupiter",
//     ),
//     const Flashcard(
//       question: "Who wrote 'Romeo and Juliet'?",
//       answer: "William Shakespeare",
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // AppBar with a bright color from our theme
//       appBar: AppBar(
//         title: const Text('Colorful Flashcards'),
//         centerTitle: true,
//       ),
//       body: Container(
//         // A simple gradient background to make the screen more colorful
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFFFFE0B2), // Light orange tone
//               Color(0xFFFFCC80), // Slightly darker orange tone
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: ListView.builder(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
//           itemCount: flashcards.length,
//           itemBuilder: (context, index) {
//             return FlashcardWidget(flashcard: flashcards[index]);
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class FlashcardWidget extends StatefulWidget {
//   final Flashcard flashcard;
//
//   const FlashcardWidget({
//     Key? key,
//     required this.flashcard,
//   }) : super(key: key);
//
//   @override
//   State<FlashcardWidget> createState() => _FlashcardWidgetState();
// }
//
// class _FlashcardWidgetState extends State<FlashcardWidget> {
//   bool _showAnswer = false;
//
//   void _toggleCard() {
//     setState(() {
//       _showAnswer = !_showAnswer;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Different background colors for question side vs. answer side
//     final cardColor = _showAnswer ? Colors.tealAccent[100] : Colors.pinkAccent[100];
//
//     return GestureDetector(
//       onTap: _toggleCard,
//       child: Card(
//         color: cardColor,
//         elevation: 6,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
//         child: SizedBox(
//           height: 150,
//           child: Center(
//             // AnimatedSwitcher to smoothly animate between question and answer
//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               transitionBuilder: (child, animation) {
//                 // You can try different animations: FadeTransition, ScaleTransition, etc.
//                 return ScaleTransition(scale: animation, child: child);
//               },
//               child: Text(
//                 _showAnswer
//                     ? widget.flashcard.answer
//                     : widget.flashcard.question,
//                 key: ValueKey<bool>(_showAnswer),
//                 style: Theme.of(context).textTheme.headlineSmall,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
