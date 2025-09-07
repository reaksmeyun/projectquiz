import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool otpSent = false;
  bool isLoading = false;

  final String countryCode = "855"; // always use your country code

  Future<void> sendOtp() async {
    setState(() => isLoading = true);

    final url = Uri.parse('https://quiz-api.camtech-dev.online/api/auth/otp/send');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "countryCode": countryCode,
          "phone": phoneController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        setState(() => otpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP sent successfully")));
      } else {
        final data = jsonDecode(response.body);
        final error = data['message'] ?? 'Failed to send OTP';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> register() async {
    setState(() => isLoading = true);

    final url = Uri.parse('https://quiz-api.camtech-dev.online/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "countryCode": countryCode,
          "phone": phoneController.text.trim(),
          "otp": otpController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        final data = jsonDecode(response.body);
        final error = data['message'] ?? 'Registration failed';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Register"), backgroundColor: Colors.deepOrange),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone",
                hintText: "Enter your phone number without country code",
              ),
            ),
            const SizedBox(height: 12),
            otpSent
                ? TextField(
                    controller: otpController,
                    decoration: const InputDecoration(labelText: "Enter OTP"),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 12),
            otpSent
                ? TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : otpSent
                    ? ElevatedButton(
                        onPressed: register,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange),
                        child: const Text("Register"),
                      )
                    : ElevatedButton(
                        onPressed: sendOtp,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange),
                        child: const Text("Send OTP"),
                      ),
          ],
        ),
      ),
    );
  }
}