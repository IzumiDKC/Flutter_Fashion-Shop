import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'HistoryOrderScreen.dart';
import 'LoginScreen.dart';
import 'ProfileDetailScreen.dart';

class ProfileOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onClick;

  const ProfileOptionCard({
    required this.title,
    required this.description,
    required this.icon,
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
          child: Row(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
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
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        userName.isNotEmpty ? userName[0] : "?",
                        style: const TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Xin chào, $userName!",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ProfileOptionCard(
                title: "Thông tin cá nhân",
                description: "Xem và cập nhật thông tin của bạn.",
                icon: Icons.person,
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
                icon: Icons.history,
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryOrderScreen(userId: userId),
                    ),
                  );
                },
              ),

              ProfileOptionCard(
                title: "Xếp hạng thành viên",
                description: "Xem xếp hạng tiêu dùng của bạn.",
                icon: Icons.star,
                onClick: () {},
              ),
              ProfileOptionCard(
                title: "Phương thức thanh toán",
                description: "Quản lý các phương thức thanh toán.",
                icon: Icons.payment,
                onClick: () {},
              ),
              ProfileOptionCard(
                title: "Trung tâm hỗ trợ",
                description: "Liên hệ hỗ trợ nếu cần giúp đỡ.",
                icon: Icons.help,
                onClick: () {},
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text(
                    "Đăng xuất",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white
                    ),
                  ),
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
