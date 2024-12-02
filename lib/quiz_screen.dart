import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'quiz_summary.dart';
import 'dart:async';

class QuizScreen extends StatefulWidget {
  final int category;
  final String difficulty;
  final String type;
  final int numQuestions;

  QuizScreen({
    required this.category,
    required this.difficulty,
    required this.type,
    required this.numQuestions,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  int timeLeft = 15;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final url =
        'https://opentdb.com/api.php?amount=${widget.numQuestions}&category=${widget.category}&difficulty=${widget.difficulty}&type=${widget.type}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        questions = json.decode(response.body)['results'];
      });
      startTimer();
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch questions. Please try again.'),
      ));
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          moveToNextQuestion(false); // Mark as incorrect
        }
      });
    });
  }

  void moveToNextQuestion(bool correct) {
    if (correct) score++;
    timer?.cancel();
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        timeLeft = 15;
      });
      startTimer();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizSummary(score: score, total: questions.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Question ${currentQuestionIndex + 1}/${questions.length}',
                  style: TextStyle(fontSize: 18),
                ),
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    questions[currentQuestionIndex]['question'],
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                ...((questions[currentQuestionIndex]['incorrect_answers'] as List)
                      ..add(questions[currentQuestionIndex]['correct_answer'])
                      ..shuffle())
                    .map((answer) {
                  return ElevatedButton(
                    onPressed: () {
                      moveToNextQuestion(
                          answer == questions[currentQuestionIndex]['correct_answer']);
                    },
                    child: Text(answer),
                  );
                }).toList(),
                Text('Time Left: $timeLeft seconds'),
              ],
            ),
    );
  }
}
