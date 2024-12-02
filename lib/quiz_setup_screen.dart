import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizSetupScreen extends StatefulWidget {
  @override
  _QuizSetupScreenState createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  List categories = [];
  int selectedCategory = 9; // Default to General Knowledge
  String difficulty = 'easy';
  String questionType = 'multiple';
  int numQuestions = 5;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body)['trivia_categories'];
      });
    } else {
      // Handle errors gracefully
      setState(() {
        categories = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch categories. Please try again later.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Setup')),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: 'Select Category'),
                    items: categories.map<DropdownMenuItem<int>>((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    value: selectedCategory,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Select Difficulty'),
                    items: ['easy', 'medium', 'hard']
                        .map<DropdownMenuItem<String>>((difficulty) {
                      return DropdownMenuItem<String>(
                        value: difficulty,
                        child: Text(difficulty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        difficulty = value!;
                      });
                    },
                    value: difficulty,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Select Question Type'),
                    items: [
                      {'value': 'multiple', 'label': 'Multiple Choice'},
                      {'value': 'boolean', 'label': 'True/False'}
                    ].map<DropdownMenuItem<String>>((type) {
                      return DropdownMenuItem<String>(
                        value: type['value'],
                        child: Text(type['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        questionType = value!;
                      });
                    },
                    value: questionType,
                  ),
                  Text('Number of Questions: $numQuestions'),
                  Slider(
                    value: numQuestions.toDouble(),
                    min: 5,
                    max: 15,
                    divisions: 2,
                    label: '$numQuestions Questions',
                    onChanged: (value) {
                      setState(() {
                        numQuestions = value.toInt();
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            category: selectedCategory,
                            difficulty: difficulty,
                            type: questionType,
                            numQuestions: numQuestions,
                          ),
                        ),
                      );
                    },
                    child: Text('Start Quiz'),
                  ),
                ],
              ),
            ),
    );
  }
}
