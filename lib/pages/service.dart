


// service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// Toggle between local and remote API
const bool useLocalApi = false; // true = local emulator, false = production

// Global baseURL (accessible from anywhere, like in HomeScreen)
final String baseURL = useLocalApi
    ? "http://10.0.2.2:8080" // Localhost for Android emulator
    : "https://quiz-api.camtech-dev.online";

// A service class for handling API requests
class ApiService {
  // Example: fetch quizzes (you can add more endpoints here)
  Future<dynamic> getQuizzes() async {
    try {
      final response = await http.get(Uri.parse('$baseURL/quizzes'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('⚠️ Failed to load quizzes: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching quizzes: $e');
      return null;
    }
  }

  // Example for future use:
  // Future<dynamic> loginUser(String phone, String password) async { ... }
}
String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTQsInBob25lIjoiMDg4NzYwNjEzNSIsImlhdCI6MTc1NzIzMzIzMywiZXhwIjoxNzg4NzkwODMzfQ.2nDyLZ6UTTjWFFiy1EFG0kyipX6JQJWaA96Xc370XGI';