import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../api/api_Client.dart';
import '../models/CreateOrderRequest.dart';
import '../models/OrderDetailRequest.dart';
import 'CheckoutScreen.dart';
import 'HistoryOrderScreen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.cart});

  final List<dynamic> cart;

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _isCartLoaded = false; // Để kiểm soát việc tải dữ liệu


  // Phương thức lưu giỏ hàng
  Future<void> _saveCartToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(widget.cart); // Chuyển danh sách thành JSON
    await prefs.setString('cart', cartJson);
  }

// Phương thức tải giỏ hàng
  Future<void> _loadCartFromPreferences() async {
    if (_isCartLoaded || widget.cart.isNotEmpty) return; // Không tải lại nếu đã có dữ liệu

    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart');
    if (cartJson != null) {
      setState(() {
        widget.cart.clear();
        widget.cart.addAll(List<Map<String, dynamic>>.from(jsonDecode(cartJson)));
      });
    }
    _isCartLoaded = true; // Đánh dấu đã tải xong
  }

  @override
  void initState() {
    super.initState();
    _loadCartFromPreferences();
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
      _saveCartToPreferences();
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (widget.cart[index]['quantity'] > 1) {
        widget.cart[index]['quantity'] -= 1;
        _saveCartToPreferences();
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      widget.cart.removeAt(index);
      _saveCartToPreferences();
    });
  }

  void _clearCart() {
    setState(() {
      widget.cart.clear(); // Làm trống giỏ hàng
      _saveCartToPreferences();
    });
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
              onPressed: () async {
                if (widget.cart.isEmpty) {
                  // Hiển thị thông báo nếu giỏ hàng trống
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Thông báo'),
                        content: const Text('Giỏ hàng của bạn đang trống. Vui lòng thêm sản phẩm để tiếp tục.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Đóng dialog
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                        cart: widget.cart,
                        totalPrice: _calculateTotalPrice(),
                        shippingAddress: "Nhập địa chỉ",
                        note: _noteController.text.isEmpty ? null : _noteController.text,
                        onClearCart: _clearCart,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Thanh toán'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                textStyle: const TextStyle(fontSize: 16),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
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