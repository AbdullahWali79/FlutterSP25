import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/quiz_score.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getQuizScores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final scores = snapshot.data ?? [];
          if (scores.isEmpty) {
            return const Center(
              child: Text(
                'No quiz scores yet.\nTake a quiz to see your progress!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return Column(
            children: [
              _buildSummaryCard(scores),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: scores.length,
                  itemBuilder: (context, index) {
                    final score = QuizScore.fromMap(scores[index]);
                    final percentage =
                        (score.score / score.totalQuestions) * 100;
                    final date = DateTime.parse(score.dateTaken);
                    final formattedDate =
                        '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          '${score.score}/${score.totalQuestions} (${percentage.toStringAsFixed(1)}%)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Quiz Type: ${score.quizType}\nDate: $formattedDate',
                        ),
                        trailing: _buildScoreIcon(percentage),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Map<String, dynamic>> scores) {
    int totalScore = 0;
    int totalQuestions = 0;

    for (final score in scores) {
      totalScore += score['score'] as int;
      totalQuestions += score['total_questions'] as int;
    }

    final averagePercentage = (totalScore / totalQuestions) * 100;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Overall Performance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${averagePercentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Total Quizzes: ${scores.length}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIcon(double percentage) {
    IconData iconData;
    Color color;

    if (percentage >= 90) {
      iconData = Icons.star;
      color = Colors.amber;
    } else if (percentage >= 70) {
      iconData = Icons.thumb_up;
      color = Colors.green;
    } else if (percentage >= 50) {
      iconData = Icons.trending_up;
      color = Colors.blue;
    } else {
      iconData = Icons.refresh;
      color = Colors.orange;
    }

    return Icon(
      iconData,
      color: color,
      size: 30,
    );
  }
}
