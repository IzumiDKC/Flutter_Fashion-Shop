import 'package:flutter/material.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatelessWidget {
  final bool isLoggedIn;

  ProfileScreen({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ Sơ"),
      ),
      body: Center(
        child: isLoggedIn
            ? const Text(
          "Chào mừng đến trang Hồ Sơ",
          style: TextStyle(fontSize: 18),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Bạn chưa đăng nhập",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text("Đăng Nhập"),
            ),
          ],
        ),
      ),
    );
  }
}
