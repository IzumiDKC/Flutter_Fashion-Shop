import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  final String userId;

  const SupportScreen({required this.userId, Key? key}) : super(key: key);

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'fashionshop.official.vn@gmail.com',
      query: 'subject=Hỗ trợ khách hàng&body=Chào Trung tâm Hỗ trợ,',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      print('Không thể mở email.');
    }

  }

  void _callSupport() {
    print("Gọi tới trung tâm hỗ trợ.");
  }

  void _sendFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Gửi phản hồi"),
        content: TextField(
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Nhập phản hồi của bạn...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Phản hồi đã được gửi!")),
              );
            },
            child: const Text("Gửi"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trung Tâm Hỗ Trợ"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text(
                    "Cần giúp đỡ?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Nếu bạn gặp vấn đề hoặc cần hỗ trợ, vui lòng liên hệ qua các phương thức dưới đây.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email, color: Colors.teal),
                title: const Text("Email"),
                subtitle: const Text("fashionshop.official.vn@gmail.com"),
                onTap: _sendEmail,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.teal),
                title: const Text("Số điện thoại"),
                subtitle: const Text("+84 398 272 171"),
                onTap: _callSupport,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.feedback, color: Colors.teal),
                title: const Text("Phản hồi"),
                subtitle: const Text("Gửi phản hồi của bạn cho chúng tôi."),
                onTap: () => _sendFeedback(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
