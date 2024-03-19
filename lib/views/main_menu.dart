import 'package:flutter/material.dart';
import 'package:quiz_app/views/question_answer_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  // Load high score from shared preferences
  _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = (prefs.getInt('highScore') ?? 0);
    });
  }

  // Function to handle pull-to-refresh action
  Future<void> _handleRefresh() async {
    await _loadHighScore(); // Wait for high score to be loaded
    setState(() {}); // Refresh UI after loading high score
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      appBar: AppBar(
        title: const Center(child: Text('Quiz App',style: TextStyle(color: Colors.white),)),
        backgroundColor: Colors.blue[900], // Dark blue color
      ),
      body: RefreshIndicator(
        color: Colors.blue[400], // Sky blue color
        backgroundColor: Colors.blue[900], // Dark blue color
        onRefresh: _handleRefresh,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuestionAnswerPage()),
                  );
                },
                child: Text('Start New Game', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400], // Sky blue color for button
                ),
              ),
              SizedBox(height: 20), // Add spacing between buttons and score
              Text(
                'High Score: $highScore',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white, // White text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
