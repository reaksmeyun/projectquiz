import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool otpSent = false;
  bool isLoading = false;

  final String baseURL = "https://quiz-api.camtech-dev.online";

  // Send OTP
  Future<void> sendOtp() async {
    setState(() => isLoading = true);

    final url = Uri.parse('$baseURL/api/auth/otp/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "countryCode": "855",
          "phone": phoneController.text.trim(),
        }),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        setState(() => otpSent = true);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("OTP sent successfully")));
      } else {
        final data = jsonDecode(response.body);
        final error = data['message'] ?? 'Failed to send OTP';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Reset Password
  Future<void> resetPassword() async {
    setState(() => isLoading = true);

    final url = Uri.parse('$baseURL/api/auth/password/reset');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "countryCode": "855",
          "phone": phoneController.text.trim(),
          "otp": otpController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Password reset successful")));
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        final error = data['message'] ?? 'Reset failed';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
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
      appBar: AppBar(
          title: const Text("Reset Password"),
          backgroundColor: Colors.deepOrange),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
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
                    decoration: const InputDecoration(labelText: "New Password"),
                    obscureText: true,
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : otpSent
                    ? ElevatedButton(
                        onPressed: resetPassword,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange),
                        child: const Text("Reset Password"),
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
