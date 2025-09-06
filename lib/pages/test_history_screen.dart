import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_history_detail_screen.dart';

class TestHistoryScreen extends StatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  List<Map<String, dynamic>> testHistory = [];
  List<Map<String, dynamic>> filteredHistory = [];
  bool isLoading = true;
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    loadTestHistory();
  }

  Future<void> loadTestHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyStr = prefs.getString("test_history");

    if (historyStr != null) {
      final List<dynamic> historyList = jsonDecode(historyStr);
      setState(() {
        testHistory = historyList.map<Map<String, dynamic>>((item) {
          return Map<String, dynamic>.from(item);
        }).toList();
        filteredHistory = List.from(testHistory);
        isLoading = false;
      });
    } else {
      setState(() {
        testHistory = [];
        filteredHistory = [];
        isLoading = false;
      });
    }
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == "All") {
        filteredHistory = List.from(testHistory);
      } else {
        filteredHistory = testHistory
            .where((test) => test['categoryEn'] == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Test History"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          // Category filter
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedCategory,
              items: [
                const DropdownMenuItem(value: "All", child: Text("All")),
                ...testHistory
                    .map<String>((test) => test['categoryEn'] as String)
                    .toSet()
                    .map(
                      (cat) => DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      ),
                    )
                    .toList(),
              ],
              onChanged: (value) {
                filterByCategory(value!);
              },
            ),
          ),
          Expanded(
            child: filteredHistory.isEmpty
                ? const Center(child: Text("No test history found"))
                : ListView.builder(
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final test = filteredHistory[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(test['categoryEn']),
                          subtitle: Text(
                              "Score: ${test['score']} / ${test['totalQuestion']} • Correct: ${test['totalCorrect']}"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TestHistoryDetailScreen(
                                    testData: test),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
