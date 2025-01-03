import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:fb88/api/api_client.dart';
import 'package:fb88/models/AuthModels.dart';
import 'package:fb88/screens/RegisterScreen.dart';

import 'ProfileScreen.dart';

class LoginScreen extends StatefulWidget {
  final Function(bool) onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;


  Future<void> login(String username, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final request = LoginRequest(username: username, password: password);

      // Call the API to login
      final response = await ApiClient().login(request);

      // Log the response to check for token
      print("Login response: ${response.data}");
      final token = response.data['token'];
      print("Token received: $token");

      // Lưu trạng thái đăng nhập vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('token', token);

      // Update login status
      widget.onLoginSuccess(true);
      print("Login success, updating status to true");

      // Navigate back to ProfileScreen
      Navigator.of(context).pop(true);

    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập thất bại. Vui lòng thử lại.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng Nhập"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Tên tài khoản",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                final username = _usernameController.text.trim();
                final password = _passwordController.text.trim();

                if (username.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Vui lòng điền đầy đủ thông tin.")),
                  );
                  return;
                }

                login(username, password);
              },
              child: const Text("Đăng Nhập"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterScreen()),
                );
              },
              child: const Text("Chưa có tài khoản? Đăng ký ngay"),
            ),
          ],
        ),
      ),
    );
  }
}