import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_Client.dart';
import '../models/UserProfile.dart';

class ProfileDetailScreen extends StatefulWidget {
  final String userId;

  ProfileDetailScreen({required this.userId});

  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late Future<UserProfile> _profile;

  @override
  void initState() {
    super.initState();
    _profile = ApiClient().getProfile(widget.userId);
    _saveUserId(widget.userId);
  }
  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    print('userId đã được lưu vào SharedPreferences: $userId');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi Tiết Hồ Sơ"),
      ),
      body: FutureBuilder<UserProfile>(
        future: _profile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tên người dùng: ${user.userName}"),
                  Text("Email: ${user.email}"),
                  Text("Họ và tên: ${user.fullName}"),
                  Text("Tuổi: ${user.age ?? 'N/A'}"),
                  Text("Địa chỉ: ${user.address ?? 'Không có thông tin'}"),
                  Text("Số điện thoại: ${user.phoneNumber ?? 'Không có thông tin'}"),
                ],
              ),
            );
          }
          return const Center(child: Text("Không có dữ liệu"));
        },
      ),
    );
  }
}