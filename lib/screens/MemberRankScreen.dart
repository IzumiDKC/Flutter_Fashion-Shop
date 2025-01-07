import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../models/Order.dart';

class MemberRankScreen extends StatefulWidget {
  final String userId;

  const MemberRankScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _MemberRankScreenState createState() => _MemberRankScreenState();
}

class _MemberRankScreenState extends State<MemberRankScreen> {
  late Future<List<Order>> _orders;
  late NumberFormat currencyFormat;

  @override
  void initState() {
    super.initState();
    _orders = ApiClient().getUserOrders(widget.userId);
    currencyFormat = NumberFormat('#,##0', 'vi_VN');
  }

  String _determineRank(double totalPrice) {
    if (totalPrice <= 500000) {
      return "Đồng";
    } else if (totalPrice <= 1000000) {
      return "Bạc";
    } else if (totalPrice <= 2000000) {
      return "Vàng";
    } else if (totalPrice <= 3500000) {
      return "Bạch kim";
    } else if (totalPrice <= 5000000) {
      return "Kim Cương";
    } else {
      return "V.I.P";
    }
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case "Đồng":
        return Colors.brown;
      case "Bạc":
        return Colors.grey;
      case "Vàng":
        return Colors.amber;
      case "Bạch kim":
        return Colors.blueGrey;
      case "Kim Cương":
        return Colors.cyan;
      case "V.I.P":
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  void _showBenefits(String rank) {
    String benefits;
    switch (rank) {
      case "Đồng":
        benefits = "Quyền lợi cơ bản.";
        break;
      case "Bạc":
        benefits = "Giảm giá 5% cho các đơn hàng.";
        break;
      case "Vàng":
        benefits = "Giảm giá 10% và ưu tiên giao hàng.";
        break;
      case "Bạch kim":
        benefits = "Giảm giá 15%, ưu tiên giao hàng và hỗ trợ khách hàng.";
        break;
      case "Kim Cương":
        benefits = "Giảm giá 20%, giao hàng miễn phí và ưu tiên hỗ trợ.";
        break;
      case "V.I.P":
        benefits = "Tất cả quyền lợi cao cấp và quà tặng đặc biệt.";
        break;
      default:
        benefits = "Không có thông tin quyền lợi.";
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Quyền Lợi - $rank"),
        content: Text(benefits),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xếp Hạng Thành Viên"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Order>>(
        future: _orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi khi tải dữ liệu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có đơn hàng nào.'));
          } else {
            double totalPrice = snapshot.data!
                .map((order) => order.totalPrice)
                .fold(0.0, (prev, current) => prev + current) * 1000;

            String rank = _determineRank(totalPrice);
            Color rankColor = _getRankColor(rank);

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 100,
                    color: rankColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Tổng giá trị đơn hàng:",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    "${currencyFormat.format(totalPrice)} VNĐ",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Hạng Thành Viên:",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    rank,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showBenefits(rank),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rankColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Quyền Lợi",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
