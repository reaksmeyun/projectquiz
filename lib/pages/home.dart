import 'package:flutter/material.dart';
import 'quiz_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedLanguage = "English";

  // Categories
  final Map<String, String> categories = {
    'Geography': '22',
    'History': '23',
    'Art': '25',
    'Animals': '27',
    'Politics': '24',
  };

  // Bottom nav tabs
  final List<String> _tabs = ["Home", "Test History", "Top Users", "Profile"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz App", style: TextStyle(color: Colors.white)),

        backgroundColor: Colors.deepOrange,

        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            dropdownColor: const Color.fromARGB(255, 234, 203, 157).withOpacity(
              0.8,
            ), // light transparent orange
            underline: const SizedBox(),
            iconEnabledColor: Colors.white, // arrow icon in white
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
      body: _currentIndex == 0
          ? Column(
              children: [
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
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories.keys.elementAt(index);
                      final categoryId = categories[category]!;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizHome(categoryId: categoryId),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.orangeAccent,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 20,
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
            )
          : Center(
              child: Text(
                "${_tabs[_currentIndex]} Page (Coming Soon)",
                style: const TextStyle(fontSize: 20),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Test History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: "Top Users",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
