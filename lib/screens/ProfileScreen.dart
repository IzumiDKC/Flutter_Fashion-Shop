import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import thư viện jwt_decoder
import 'LoginScreen.dart';
import 'ProfileDetailScreen.dart';

class ProfileOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onClick;

  const ProfileOptionCard({
    required this.title,
    required this.description,
    required this.onClick,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge, // Updated from headline6 to titleLarge
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.titleLarge, // Updated from headline6 to titleLarge
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final Function(bool) onLoginSuccess;

  const ProfileScreen({
    required this.onLoginSuccess,
    Key? key,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "";
  String userId = "";
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
      String? token = prefs.getString('token');
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        setState(() {
          userName = decodedToken['name'] ?? 'Người dùng';
          userId = decodedToken['userId'] ?? '';
        });
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('token');
    widget.onLoginSuccess(false);
    setState(() {
      isLoggedIn = false;
      userName = '';
      userId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ Sơ"),
      ),
      body: isLoggedIn
          ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Xin chào, $userName!",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ProfileOptionCard(
                title: "Thông tin cá nhân",
                description: "Xem và cập nhật thông tin của bạn.",
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileDetailScreen(userId: userId),
                    ),
                  );
                },
              ),
              ProfileOptionCard(
                title: "Lịch sử đơn hàng",
                description: "Xem lại các đơn hàng đã đặt.",
                onClick: () {
                  // TODO: Chuyển sang màn hình lịch sử đơn hàng
                },
              ),
              ProfileOptionCard(
                title: "Xếp hạng thành viên",
                description: "Xem xếp hạng tiêu dùng của bạn.",
                onClick: () {
                  // TODO: Chuyển sang màn hình xếp hạng thành viên
                },
              ),
              ProfileOptionCard(
                title: "Phương thức thanh toán",
                description: "Quản lý các phương thức thanh toán.",
                onClick: () {
                  // TODO: Chuyển sang màn hình phương thức thanh toán
                },
              ),
              ProfileOptionCard(
                title: "Trung tâm hỗ trợ",
                description: "Liên hệ hỗ trợ nếu cần giúp đỡ.",
                onClick: () {
                  // TODO: Chuyển sang màn hình trung tâm hỗ trợ
                },
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text("Đăng xuất"),
                ),
              ),
            ],
          ),
        ),
      )
          : Center(
        child: Column(
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
                ) ??
                    false;

                if (loginSuccess) {
                  _loadLoginStatus();
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