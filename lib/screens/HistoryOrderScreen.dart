import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../models/Order.dart';

class HistoryOrderScreen extends StatefulWidget {
  final String userId;

  const HistoryOrderScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _HistoryOrderScreenState createState() => _HistoryOrderScreenState();
}

class _HistoryOrderScreenState extends State<HistoryOrderScreen> {
  late Future<List<Order>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = ApiClient().getUserOrders(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat('#,##0.000', 'vi_VN');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử đơn hàng"),
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
            List<Order> orders = snapshot.data!;
            orders.sort((a, b) => b.id.compareTo(a.id));

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                Order order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(Icons.shopping_bag, color: Colors.teal),
                    title: Text(
                      'Đơn hàng #${order.id}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(order.orderDate))}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        Text(
                          'Tổng tiền: ${currencyFormat.format(order.totalPrice)} VNĐ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.teal[700],
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(order: order),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({required this.order, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat('#,##0.000', 'vi_VN');

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết đơn hàng #${order.id}"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Địa chỉ giao hàng: ${order.shippingAddress}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Trạng thái: ${order.status}',
              style: const TextStyle(fontSize: 16),
            ),
            if (order.notes != null)
              Text(
                'Ghi chú: ${order.notes}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            const Text(
              'Chi tiết sản phẩm:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: order.orderDetails.length,
                itemBuilder: (context, index) {
                  var detail = order.orderDetails[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        detail.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      subtitle: Text(
                        'Giá: ${currencyFormat.format(detail.finalPrice)} x ${detail.quantity} (Giá gốc: ${currencyFormat.format(detail.originalPrice)})',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
