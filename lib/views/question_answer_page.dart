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
  int currentScore = 0; // Variable to track the current score
  int currentQuestionIndex = 0; // Variable to track the index of the current question
  late List<Question> questions = GlobalQuestions.questions; // List of questions in the quiz
  bool answered = false; // Flag to indicate if the question has been answered
  late String selectedAnswer; // Variable to store the selected answer
  Timer? _timer; // Timer for tracking time left to answer each question
  final QuizService _quizService = QuizService(); // Service for managing quiz-related operations
  int _timeLeft = 10; // Time limit for answering each question in seconds
  bool _timeExpired = false; // Flag to indicate if the time limit has expired

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start the timer when the page is initialized
  }

  /// Starts the timer for each question, reducing the time left by 1 second every second.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer!.cancel();
          _timeExpired = true;
          _answerQuestion(''); // Consider unanswered question as incorrect when time expires
        }
      });
    });
  }

  /// Handles the user's answer to the question.
  void _answerQuestion(String answer) {
    if (answered || _timeExpired) return; // Do nothing if the question is already answered or time has expired

    setState(() {
      answered = true; // Mark the question as answered
      selectedAnswer = answer; // Store the selected answer
      // Check if the selected answer is correct and update the score accordingly
      if (questions[currentQuestionIndex].correctAnswer == answer) {
        currentScore += questions[currentQuestionIndex].score;
      }
    });

    _timer?.cancel(); // Cancel the timer when the question is answered

    _timer = Timer(const Duration(seconds: 2), () {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++; // Move to the next question
          answered = false; // Reset the answered flag for the next question
          _timeLeft = 10; // Reset the time left for answering the next question
          _timeExpired = false; // Reset the timeExpired flag for the next question
        });
        _startTimer(); // Start the timer for the next question
      } else {
        _updateHighScore(); // Update the high score and navigate back to the main menu when all questions are answered
      }
    });
  }

  /// Updates the high score if the current score is higher and navigates back to the main menu.
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
    _timer?.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Question currentQuestion = questions[currentQuestionIndex]; // Get the current question
    return Scaffold(
      backgroundColor: Colors.blue.shade700, // Set background color
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900, // Set app bar color
        iconTheme: const IconThemeData(color: Colors.white),  // Set back button color to white
        title: Center(child: Text('Question ${currentQuestionIndex + 1} of ${questions.length}', style: const TextStyle(color: Colors.white),)), // Display current question number
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(child: Text('Score: $currentScore', style: const TextStyle(fontSize: 16, color: Colors.yellowAccent),)), // Display current score
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            elevation: 8.0,
            color: Colors.blue.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (currentQuestion.questionImageUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    child: Image.network(
                      currentQuestion.questionImageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),

                ///question ans score section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Table(
                    columnWidths: {
                      0: const FlexColumnWidth(3),
                      1: const FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              currentQuestion.questionText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Score\n${currentQuestion.score}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 0),
                const SizedBox(height: 10),
                ...currentQuestion.answers.keys.map((answer) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      color: answered  ///controlling answer based on user answer selection
                          ? (answer == selectedAnswer
                          ? (answer == currentQuestion.correctAnswer ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7))
                          : (answer == currentQuestion.correctAnswer ? Colors.green.withOpacity(0.7) : null))
                          : Colors.blue.shade800,
                    ),
                    child: ListTile(
                      title: Center(
                        child: Text(
                          currentQuestion.answers[answer]!,
                          style: const TextStyle(color: Colors.white, fontSize: 20),
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
      bottomNavigationBar: LinearProgressIndicator(
        backgroundColor: Colors.grey.shade400,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        value: _timeLeft / 10, // Progress based on the time left
      ),
    );
  }
}

