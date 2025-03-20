class QuizScore {
  final int? id;
  final int score;
  final int totalQuestions;
  final String quizType;
  final String dateTaken;

  QuizScore({
    this.id,
    required this.score,
    required this.totalQuestions,
    required this.quizType,
    required this.dateTaken,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'score': score,
      'total_questions': totalQuestions,
      'quiz_type': quizType,
      'date_taken': dateTaken,
    };
  }

  factory QuizScore.fromMap(Map<String, dynamic> map) {
    return QuizScore(
      id: map['id'] as int,
      score: map['score'] as int,
      totalQuestions: map['total_questions'] as int,
      quizType: map['quiz_type'] as String,
      dateTaken: map['date_taken'] as String,
    );
  }
}
