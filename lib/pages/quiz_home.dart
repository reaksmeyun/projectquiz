import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projectquiz/pages/service.dart';

class QuizHome extends StatefulWidget {
  final int categoryId;
  const QuizHome({super.key, required this.categoryId});

  @override
  State<QuizHome> createState() => _QuizHomeState();
}

class _QuizHomeState extends State<QuizHome> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  String selectedLanguage = "English";
  bool isLoading = true;

  String? selectedAnswer; // Track selected answer
  bool answered = false; // Flag to prevent multiple taps

  // Bearer token
  final String bearerToken = token;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final url = Uri.parse(
        'https://quiz-api.camtech-dev.online/api/category/${widget.categoryId}/detail');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $bearerToken',
      });

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded['questions'] ?? [];

        setState(() {
          questions = data.map<Map<String, dynamic>>((q) {
            return {
              'id': q['id'],
              'questionEn': q['questionEn'],
              'questionKh': q['questionKh'],
              'questionZh': q['questionZh'],
              'answerCode': q['answerCode'],
              'optionsEn': q['optionEn'],
              'optionsKh': q['optionKh'],
              'optionsZh': q['optionZh'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          questions = [];
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        questions = [];
      });
    }
  }

  String getQuestionText(Map<String, dynamic> question) {
    switch (selectedLanguage) {
      case "Khmer":
        return question['questionKh'] ?? question['questionEn'];
      case "Chinese":
        return question['questionZh'] ?? question['questionEn'];
      default:
        return question['questionEn'];
    }
  }

  List<String> getOptions(Map<String, dynamic> question) {
    switch (selectedLanguage) {
      case "Khmer":
        return List<String>.from(question['optionsKh'] ?? question['optionsEn']);
      case "Chinese":
        return List<String>.from(question['optionsZh'] ?? question['optionsEn']);
      default:
        return List<String>.from(question['optionsEn']);
    }
  }

  void selectAnswer(String answer) {
    if (answered) return; // prevent multiple taps

    setState(() {
      selectedAnswer = answer;
      answered = true;
    });

    // Wait 1 second then go to next question
    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
          answered = false;
        });
      } else {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text("Quiz Completed"),
                  content: const Text("You have finished the quiz."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ));
      }
    });
  }

  Color getOptionColor(String option, String correctAnswer) {
    if (!answered) return Colors.deepOrange; // default button color
    if (option == correctAnswer) return Colors.green; // correct
    if (option == selectedAnswer && option != correctAnswer) return Colors.red; // wrong
    return Colors.deepOrange; // other options remain default
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No questions found.")),
      );
    }

    final question = questions[currentQuestionIndex];
    final options = getOptions(question);
    final correctAnswer = question['answerCode'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        backgroundColor: Colors.deepOrange,
        actions: [
          DropdownButton<String>(
            value: selectedLanguage,
            dropdownColor: Colors.deepOrange.shade100,
            underline: const SizedBox(),
            iconEnabledColor: Colors.white,
            onChanged: (value) {
              setState(() {
                selectedLanguage = value!;
              });
            },
            items: const [
              DropdownMenuItem(value: "English", child: Text("English")),
              DropdownMenuItem(value: "Khmer", child: Text("Khmer")),
              DropdownMenuItem(value: "Chinese", child: Text("Chinese")),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Question ${currentQuestionIndex + 1}/${questions.length}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              getQuestionText(question),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            ...options.map((option) => ElevatedButton(
                  onPressed: () => selectAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getOptionColor(option, correctAnswer),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 18)),
                )),
          ],
        ),
      ),
    );
  }
}
