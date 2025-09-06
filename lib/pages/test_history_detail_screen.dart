import 'package:flutter/material.dart';

class TestHistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> testData;

  const TestHistoryDetailScreen({super.key, required this.testData});

  @override
  Widget build(BuildContext context) {
    final questions = testData['questions'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Detail"),
        backgroundColor: Colors.deepOrange,
      ),
      body: questions.isEmpty
          ? const Center(child: Text("No questions found"))
          : ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final userAnswer = q['userAnswer'] ?? "N/A";
                final correctAnswer = q['answerCode'] ?? "N/A";

                return Card(
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Q${index + 1}: ${q['questionEn'] ?? 'Question'}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your Answer: $userAnswer",
                          style: TextStyle(
                            fontSize: 16,
                            color: userAnswer == correctAnswer
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Text(
                          "Correct Answer: $correctAnswer",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
