import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/UserProfile.dart';  // Đảm bảo import đúng model của bạn

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
    _profile = getProfile(widget.userId);  // Gọi API với userId
  }

  Future<UserProfile> getProfile(String userId) async {
    try {
      final response = await Dio().get("https://6c10-103-205-97-242.ngrok-free.app/api/account/profile/$userId");
      return UserProfile.fromJson(response.data);
    } catch (e) {
      throw Exception("Lỗi khi GET thông tin người dùng: $e");
    }
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
                  Text("Tuổi: ${user.age}"),
                  Text("Địa chỉ: ${user.address}"),
                  Text("Số điện thoại: ${user.phoneNumber}"),
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
