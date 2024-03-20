import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/questions.dart';
import '../models/question_model.dart';

class QuizService {
  static const String _url = 'https://herosapp.nyc3.digitaloceanspaces.com/quiz.json';

  static Future<void> fetchQuestions() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode == 200) {
      final List<dynamic> questionJson = json.decode(response.body)['questions'];
      GlobalQuestions.questions = questionJson.map((json) => Question.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }

}
