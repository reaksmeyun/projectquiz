import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'result_screen.dart';

class QuizHome extends StatefulWidget {
  final String categoryId;
  const QuizHome({super.key, required this.categoryId});

  @override
  State<QuizHome> createState() => _QuizHomeState();
}

class _QuizHomeState extends State<QuizHome> {
  List<Map<String, dynamic>> quizList = [];
  int currentIndex = 0;
  String? selectedOption;
  bool isLoading = true;
  String? sessionToken;

  @override
  void initState() {
    super.initState();
    initSessionToken();
  }

  // Initialize session token
  Future<void> initSessionToken() async {
    final tokenResp = await http.get(Uri.parse(
        'https://opentdb.com/api_token.php?command=request'));
    if (tokenResp.statusCode == 200) {
      final data = jsonDecode(tokenResp.body);
      sessionToken = data['token'];
      fetchQuiz(widget.categoryId);
    }
  }

  // Fetch quiz questions from API
  Future<void> fetchQuiz(String categoryId) async {
    setState(() {
      isLoading = true;
      selectedOption = null;
      quizList = [];
      currentIndex = 0;
    });

    final url =
        'https://opentdb.com/api.php?amount=10&category=$categoryId&type=multiple&encode=url3986&token=$sessionToken';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['response_code'] == 0) {
        final unescape = HtmlUnescape();
        quizList = (data['results'] as List)
            .map((q) => {
                  'question': unescape.convert(Uri.decodeComponent(q['question'])),
                  'correct_answer': unescape.convert(Uri.decodeComponent(q['correct_answer'])),
                  'options': [
                    ...q['incorrect_answers']
                        .map((e) => unescape.convert(Uri.decodeComponent(e)))
                        .toList(),
                    unescape.convert(Uri.decodeComponent(q['correct_answer']))
                  ]..shuffle(),
                  'score': 0
                })
            .toList();
      }
    }

    setState(() => isLoading = false);
  }

  // Handle Next button
  void nextQuestion() {
  if (quizList.isEmpty) return; // Safety check

  // Mark score for current question
  if (selectedOption == quizList[currentIndex]['correct_answer']) {
    quizList[currentIndex]['score'] = 1;
  } else {
    quizList[currentIndex]['score'] = 0;
  }

  if (currentIndex < quizList.length - 1) {
    setState(() {
      currentIndex++;
      selectedOption = null;
    });
  } else {
    // Calculate total score safely
    final totalScore = quizList.fold<int>(
      0,
      (sum, q) => sum + ((q['score'] is int) ? q['score'] as int : 0),
    );

    // Navigate to ResultScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ResultScreen(score: totalScore, total: quizList.length),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.deepOrange],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Question card
                Card(
                  key: ValueKey(currentIndex),
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          quizList[currentIndex]['question'],
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Options
                        ...quizList[currentIndex]['options'].map<Widget>((opt) {
                          final color = selectedOption == null
                              ? Colors.white
                              : (opt == quizList[currentIndex]['correct_answer']
                                  ? Colors.green
                                  : (selectedOption == opt
                                      ? Colors.red
                                      : Colors.white));
                          return GestureDetector(
                            onTap: () => setState(() => selectedOption = opt),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black12),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(2, 2)),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  opt,
                                  style: TextStyle(
                                      color: selectedOption == null
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 18),
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed:
                              selectedOption != null ? nextQuestion : null,
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 14),
                              backgroundColor: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          child: const Text(
                            'Next',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
