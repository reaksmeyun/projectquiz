import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'service.dart'; // Make sure baseURL and token are defined
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  bool isUpdating = false;
  Map<String, dynamic> profile = {};

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  final TextEditingController oldPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  File? imageFile;

  final String bearerToken = token;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final url = Uri.parse('$baseURL/api/profile/info');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $bearerToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          profile = data;
          nameController.text = data['name'] ?? '';
          ageController.text = data['age']?.toString() ?? '';
          emailController.text = data['email'] ?? '';
          schoolController.text = data['school'] ?? '';
          genderController.text = data['gender'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> updateProfile() async {
    setState(() => isUpdating = true);
    final url = Uri.parse('$baseURL/api/profile/info/update');

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $bearerToken';

    request.fields['name'] = nameController.text;
    request.fields['age'] = ageController.text;
    request.fields['email'] = emailController.text;
    request.fields['school'] = schoolController.text;
    request.fields['gender'] = genderController.text;

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('profileImage', imageFile!.path));
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")));
        fetchProfile();
      } else {
        final error = jsonDecode(respStr)['message'] ?? 'Update failed';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isUpdating = false);
    }
  }

  Future<void> changePassword() async {
    final url = Uri.parse('$baseURL/api/profile/password/change');

    if (newPassController.text != confirmPassController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'oldPassword': oldPassController.text,
          'newPassword': newPassController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Password changed successfully")));
        oldPassController.clear();
        newPassController.clear();
        confirmPassController.clear();
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Change failed';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imageFile != null
                    ? FileImage(imageFile!)
                    : profile['profileImage'] != null
                        ? NetworkImage(profile['profileImage']) as ImageProvider
                        : const AssetImage('images/default_avatar.png'),
              ),
            ),
            const SizedBox(height: 16),

            // Profile Form
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: ageController, decoration: const InputDecoration(labelText: "Age"), keyboardType: TextInputType.number),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email"), keyboardType: TextInputType.emailAddress),
            TextField(controller: schoolController, decoration: const InputDecoration(labelText: "School")),
            TextField(controller: genderController, decoration: const InputDecoration(labelText: "Gender")),

            const SizedBox(height: 12),
            isUpdating
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: updateProfile,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                    child: const Text("Update Profile"),
                  ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Password Change
            TextField(controller: oldPassController, decoration: const InputDecoration(labelText: "Old Password"), obscureText: true),
            TextField(controller: newPassController, decoration: const InputDecoration(labelText: "New Password"), obscureText: true),
            TextField(controller: confirmPassController, decoration: const InputDecoration(labelText: "Confirm New Password"), obscureText: true),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: changePassword,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              child: const Text("Change Password"),
            ),

            const SizedBox(height: 24),

            // Stats
            Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: const Text("Total Tests Taken"),
                trailing: Text(profile['totalTests']?.toString() ?? '0'),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: const Text("Total Score"),
                trailing: Text(profile['totalScore']?.toString() ?? '0'),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: const Text("League Ranking"),
                trailing: Text(profile['leagueRank']?.toString() ?? 'N/A'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
