import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'quiz_screen.dart';
import 'service.dart'; // Make sure baseURL is defined here
import 'test_history_screen.dart'; // Import TestHistoryScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedLanguage = "English";

  // Categories list
  List<Map<String, dynamic>> categories = [];

  // Bottom nav tabs
  final List<String> _tabs = ["Home", "Test History", "Top Users", "Profile"];

  // Your Bearer token
  final String bearerToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTQsInBob25lIjoiMDg4NzYwNjEzNSIsImlhdCI6MTc1NzIzMzIzMywiZXhwIjoxNzg4NzkwODMzfQ.2nDyLZ6UTTjWFFiy1EFG0kyipX6JQJWaA96Xc370XGI';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // Fetch categories from API with token
// Fetch categories from API with token
Future<void> fetchCategories() async {
  final url = Uri.parse('$baseURL/api/category/list');
  print("➡️ Fetching categories from: $url");

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Accept': 'application/json',
      },
    );

    print("⬅️ Response status: ${response.statusCode}");
    print("⬅️ Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      setState(() {
        categories = data.map<Map<String, dynamic>>((cat) => {
              'id': cat['id'],
              'nameEn': cat['nameEn'] ?? cat['nameEnn'], // ✅ fallback
              'nameKh': cat['nameKh'],
              'nameZh': cat['nameZh'],
              'iconUrl': cat['iconUrl'],
            }).toList();
      });
    } else {
      print("⚠️ Unexpected status: ${response.statusCode}");
      setState(() => categories = []);
    }
  } catch (e) {
    print("❌ Error fetching categories: $e");
    setState(() => categories = []);
  }
}


  // Get category name based on selected language
  String getCategoryName(Map<String, dynamic> category) {
    switch (_selectedLanguage) {
      case "Khmer":
        return category['nameKh'] ?? category['nameEn'];
      case "Chinese":
        return category['nameZh'] ?? category['nameEn'];
      default:
        return category['nameEn'];
    }
  }

  // Build Home tab content (banner + categories)
  Widget buildHomeContent() {
    return Column(
      children: [
        // Banner
        Container(
          height: 180,
          width: double.infinity,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.deepOrange.shade200,
            image: const DecorationImage(
              image: AssetImage("images/banner.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            "Test Your Knowledge!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // Categories Grid
        Expanded(
          child: categories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final categoryId = category['id'];
                    final categoryName = getCategoryName(category);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                QuizScreen(categoryId: categoryId),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.orangeAccent,
                          image: category['iconUrl'] != null
                              ? DecorationImage(
                                  image: NetworkImage(category['iconUrl']),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withAlpha(128),
                                    BlendMode.darken,
                                  ),
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          categoryName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine which tab to display
    Widget currentTab;
    if (_currentIndex == 0) {
      currentTab = buildHomeContent();
    } else if (_currentIndex == 1) {
      currentTab = const TestHistoryScreen(); // Show Test History tab
    } else {
      currentTab = Center(
        child: Text(
          "${_tabs[_currentIndex]} Page (Coming Soon)",
          style: const TextStyle(fontSize: 20),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz App", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            dropdownColor: const Color.fromARGB(255, 234, 203, 157)
                .withAlpha(204),
            underline: const SizedBox(),
            iconEnabledColor: Colors.white,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
            items: const [
              DropdownMenuItem(
                value: "English",
                child: Text("English", style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: "Khmer",
                child: Text("Khmer", style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: "Chinese",
                child: Text("Chinese", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
      body: currentTab,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Test History"),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: "Top Users"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}