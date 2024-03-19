import 'dart:convert';

class Question {
  final String questionText;
  final Map<String, String> answers;
  final String correctAnswer;
  final int score;
  final String? questionImageUrl;

  Question({
    required this.questionText,
    required this.answers,
    required this.correctAnswer,
    required this.score,
    this.questionImageUrl,
  });
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['question'],
      answers: Map<String, String>.from(json['answers']),
      questionImageUrl: json['questionImageUrl'] != "null" ? json['questionImageUrl'] : null,
      correctAnswer: json['correctAnswer'],
      score: json['score'],
    );
  }

  List<Question> parseQuestions(String jsonResponse) {
    final parsed = json.decode(jsonResponse).cast<Map<String, dynamic>>();
    return parsed.map<Question>((json) => Question.fromJson(json)).toList();
  }
}


