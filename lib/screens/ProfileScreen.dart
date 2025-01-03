import 'package:flutter/material.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isLoggedIn;
  final Function(bool) onLoginSuccess;

  ProfileScreen({required this.isLoggedIn, required this.onLoginSuccess});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "";

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      setState(() {
        userName = "User đã đăng nhập"; // Can replace with actual username from token if available
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ Sơ"),
      ),
      body: Center(
        child: widget.isLoggedIn
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Xin chào, $userName",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              "Chào mừng đến trang Hồ Sơ",
              style: TextStyle(fontSize: 18),
            ),
          ],
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
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(onLoginSuccess: widget.onLoginSuccess),
                  ),
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

