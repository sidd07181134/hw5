import 'package:flutter/material.dart';

class QuizSummary extends StatelessWidget {
  final int score;
  final int total;

  QuizSummary({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Summary')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You scored $score out of $total!'),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Retake Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
