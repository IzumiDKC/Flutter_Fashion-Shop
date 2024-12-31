import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng Ký")),
      body: Center(
        child: Text(
          "Trang Đăng Ký",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
