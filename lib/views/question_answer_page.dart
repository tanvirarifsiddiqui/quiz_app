import 'package:flutter/material.dart';
import 'package:quiz_app/data/questions.dart';
import 'package:quiz_app/services/quiz_service.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/question_model.dart';

class QuestionAnswerPage extends StatefulWidget {
  @override
  _QuestionAnswerPageState createState() => _QuestionAnswerPageState();
}

class _QuestionAnswerPageState extends State<QuestionAnswerPage> {
  int currentScore = 0;
  int currentQuestionIndex = 0;
  late List<Question> questions = GlobalQuestions.questions;
  bool answered = false;
  late String selectedAnswer;
  Timer? _timer;
  final QuizService _quizService = QuizService();

  @override
  void initState() {
    super.initState();
  }

  void _answerQuestion(String answer) {
    if (answered) return;

    setState(() {
      answered = true;
      selectedAnswer = answer;
      if (questions[currentQuestionIndex].correctAnswer == answer) {
        currentScore += questions[currentQuestionIndex].score;
      }
    });

    _timer = Timer(Duration(seconds: 2), () {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          answered = false;
        });
      } else {
        _updateHighScore();
      }
    });
  }

  void _updateHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    int highScore = (prefs.getInt('highScore') ?? 0);
    if (currentScore > highScore) {
      await prefs.setInt('highScore', currentScore);
    }
    Navigator.pop(context); // Return to main menu after finishing the quiz
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Question currentQuestion = questions[currentQuestionIndex];
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        iconTheme: IconThemeData(color: Colors.white),  // Set back button color to white
        title: Center(child: Text('Question ${currentQuestionIndex + 1} of ${questions.length}', style: TextStyle(color: Colors.white),)),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(child: Text('Score: $currentScore', style: TextStyle(fontSize: 16, color: Colors.yellowAccent),)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                elevation: 8.0,
                color: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (currentQuestion.questionImageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                        child: Image.network(
                          currentQuestion.questionImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        currentQuestion.questionText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(height: 0),
                    SizedBox(height: 10),
                    ...currentQuestion.answers.keys.map((answer) {
                      return Container(
                        // padding: EdgeInsets.all(0),
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                          color: answered
                              ? (answer == selectedAnswer
                              ? (answer == currentQuestion.correctAnswer ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7))
                              : (answer == currentQuestion.correctAnswer ? Colors.green.withOpacity(0.7) : null))
                              : Colors.blueAccent,
                        ),
                        child: ListTile(
                          title: Center(
                            child: Text(
                              currentQuestion.answers[answer]!,
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          onTap: () => _answerQuestion(answer),
                        ),
                      );

                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
