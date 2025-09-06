import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projectquiz/pages/service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int categoryId;
  const QuizScreen({super.key, required this.categoryId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  String selectedLanguage = "English";
  bool isLoading = true;

  String? selectedAnswer;
  bool answered = false;

  int score = 0;
  int totalCorrect = 0;

  String categoryEn = "";
  String categoryKh = "";
  String categoryZh = "";

  // Store user answers
  List<Map<String, String>> userAnswers = [];

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

      // Shuffle the questions randomly
      data.shuffle();

      // Pick only first 10 questions or all if less than 10
      final List limitedData = data.length > 10 ? data.sublist(0, 10) : data;

      setState(() {
        categoryEn = decoded['nameEn'] ?? "Category";
        categoryKh = decoded['nameKh'] ?? "Category";
        categoryZh = decoded['nameZh'] ?? "Category";

        questions = limitedData.map<Map<String, dynamic>>((q) {
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
    if (answered) return;

    setState(() {
      selectedAnswer = answer;
      answered = true;
    });
  }

  Color getOptionColor(String option, String correctAnswer) {
    if (!answered) return Colors.deepOrange;
    if (option == correctAnswer) return Colors.green;
    if (option == selectedAnswer && option != correctAnswer) return Colors.red;
    return Colors.deepOrange;
  }

  Future<void> submitResult() async {
    final url = Uri.parse("https://quiz-api.camtech-dev.online/api/report/submit");

    final body = {
      "score": score,
      "totalQuestion": questions.length,
      "totalCorrect": totalCorrect,
      "categoryEn": categoryEn,
      "categoryKh": categoryKh,
      "categoryZh": categoryZh,
      "userId": 14, // replace with logged-in user id
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $bearerToken",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("✅ Result submitted: ${response.body}");
      } else {
        print("❌ Failed to submit result: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error submitting result: $e");
    }
  }

  Future<void> saveTestLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final String? existing = prefs.getString("test_history");
    List<dynamic> history = existing != null ? jsonDecode(existing) : [];

    final newTest = {
      "id": DateTime.now().millisecondsSinceEpoch, // local unique id
      "score": score,
      "totalQuestion": questions.length,
      "totalCorrect": totalCorrect,
      "categoryEn": categoryEn,
      "categoryKh": categoryKh,
      "categoryZh": categoryZh,
      "questions": userAnswers,
    };

    history.add(newTest);
    await prefs.setString("test_history", jsonEncode(history));
  }

  void nextQuestion() async {
    if (!answered) return;

    final correctAnswer = questions[currentQuestionIndex]['answerCode'];
    userAnswers.add({
      "questionEn": questions[currentQuestionIndex]['questionEn'],
      "userAnswer": selectedAnswer ?? "",
      "answerCode": correctAnswer,
    });

    if (selectedAnswer == correctAnswer) {
      score += 1;
      totalCorrect += 1;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        answered = false;
      });
    } else {
      // Quiz finished
      await submitResult();
      await saveTestLocally();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(score: score, total: questions.length),
        ),
      );
    }
  }

  void prevQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        selectedAnswer = null;
        answered = false;
      });
    }
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
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context); // exit without saving
            },
          ),
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
            ...options.map(
              (option) => Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () => selectAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getOptionColor(option, correctAnswer),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: prevQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  onPressed: nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: Text(
                    currentQuestionIndex == questions.length - 1
                        ? "Finish"
                        : "Next",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
