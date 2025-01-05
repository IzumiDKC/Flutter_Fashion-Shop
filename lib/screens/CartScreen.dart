import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_Client.dart';
import '../models/CreateOrderRequest.dart';
import '../models/OrderDetailRequest.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.cart});

  final List<dynamic> cart;

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _noteController = TextEditingController();
  @override
  void initState() {
    super.initState();
    for (var product in widget.cart) {
      if (product['quantity'] == null || product['quantity'] <= 0) {
        product['quantity'] = 1;
      }
    }
  }

  double _calculateTotalPrice() {
    return widget.cart.fold(
      0.0,
          (sum, product) => sum + (product['finalPrice'] * product['quantity']),
    );
  }

  void _increaseQuantity(int index) {
    setState(() {
      widget.cart[index]['quantity'] += 1;
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (widget.cart[index]['quantity'] > 1) {
        widget.cart[index]['quantity'] -= 1;
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      widget.cart.removeAt(index);
    });
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }


  void _placeOrder() async {
    final userId = await _getUserId();
    final token = await _getToken();
    print('userId được lấy từ SharedPreferences trong CartScreen: $userId');
    print('Token được lấy từ SharedPreferences trong CartScreen: $token');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không tìm thấy userId')),
      );
      return;
    }

    try {
      final profile = await ApiClient().getProfile(userId);
      final shippingAddress = profile.address?.toString() ?? "Không có thông tin địa chỉ";


      final orderDetailRequests = widget.cart.map((product) {
        return OrderDetailRequest(
          productId: product['id'] ?? 0,
          quantity: product['quantity'] ?? 1,
        );
      }).toList();

      print('Danh sách sản phẩm (JSON): ${orderDetailRequests.map((e) => e.toJson()).toList()}');

      final createOrderRequest = CreateOrderRequest(
        userId: userId,
        totalPrice: _calculateTotalPrice(),
        shippingAddress: shippingAddress,
        notes: _noteController.text.isEmpty ? null : _noteController.text,
        orderDetails: orderDetailRequests,
      );

      print('Dữ liệu CreateOrderRequest: ${createOrderRequest.toJson()}');


      final order = await ApiClient().createOrder(createOrderRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đơn hàng đã được lưu thành công!')),
      );

      setState(() {
        widget.cart.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu đơn hàng: $e')),
      );
      print('Loi khi luu don hang: $e');
    }
  }

  void _confirmPayment() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận thanh toán'),
          content: const Text('Bạn có chắc chắn muốn thanh toán không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Có'),
              onPressed: () {
                Navigator.of(context).pop();
                _placeOrder();
              },
            ),
            TextButton(
              child: const Text('Không'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ Hàng'),
        actions: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _confirmPayment,
                child: const Text('Thanh toán'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  textStyle: const TextStyle(fontSize: 16), // Màu chữ
                  elevation: 8, // Tạo bóng đổ mạnh mẽ
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // Đường viền mềm mại
                  ),
                ),
              )

          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.cart.isEmpty
                ? const Center(child: Text('Giỏ hàng trống!'))
                : ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                final product = widget.cart[index];
                return ListTile(
                  leading: Image.network(
                    product['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${product['finalPrice'].toStringAsFixed(3)} VNĐ'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => _decreaseQuantity(index),
                          ),
                          Text('${product['quantity']}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _increaseQuantity(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeFromCart(index),
                  ),
                );
              },
            ),
          ),

          // Phần ghi chú nằm trên tổng tiền
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (nếu có)',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Phần tổng tiền
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${totalPrice.toStringAsFixed(3)} VNĐ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}