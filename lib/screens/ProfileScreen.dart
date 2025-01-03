import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import thư viện jwt_decoder
import 'LoginScreen.dart';
import 'ProfileDetailScreen.dart'; // Import màn hình ProfileDetailScreen

class ProfileScreen extends StatefulWidget {
  final Function(bool) onLoginSuccess;

  ProfileScreen({
    required this.onLoginSuccess, required bool isLoggedIn, required String userName,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "";
  String userId = ""; // Thêm biến userId
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });

    if (isLoggedIn) {
      String? token = prefs.getString('token'); // Lấy token từ SharedPreferences
      if (token != null) {
        // Phân giải token để lấy username và userId
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        setState(() {
          userName = decodedToken['name'] ?? '';
          userId = decodedToken['userId'] ?? '';  // Giả sử 'userId' là một phần trong token
          print("username: $userName, userId: $userId");
        });
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('token'); // Xóa token khi đăng xuất
    widget.onLoginSuccess(false);
    setState(() {
      isLoggedIn = false;
      userName = '';
      userId = '';  // Xóa userId khi đăng xuất
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ Sơ"),
      ),
      body: Center(
        child: isLoggedIn
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Điều hướng tới ProfileDetailScreen và truyền userId từ token
                final profile = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileDetailScreen(userId: userId),  // Truyền userId đã lấy
                  ),
                );
              },
              child: const Text("Xem Thông Tin"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Text("Đăng Xuất"),
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
              onPressed: () async {
                bool loginSuccess = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(onLoginSuccess: (bool) {}),
                  ),
                ) ?? false;

                if (loginSuccess) {
                  _loadLoginStatus();  // Cập nhật lại trạng thái sau khi đăng nhập thành công
                }
              },
              child: const Text("Đăng Nhập"),
            ),
          ],
        ),
      ),
    );
  }
}
