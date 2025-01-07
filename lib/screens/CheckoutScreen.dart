import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../api/api_Client.dart';
import '../models/CreateOrderRequest.dart';
import '../models/OrderDetailRequest.dart';
enum PaymentMethod { cash, vnpay, bank }

class CheckoutScreen extends StatefulWidget {
  final List<dynamic> cart;
  final double totalPrice;
  final String? shippingAddress;
  final String? note;
  final VoidCallback onClearCart;

  const CheckoutScreen({
    Key? key,
    required this.cart,
    required this.totalPrice,
    this.shippingAddress,
    this.note,
    required this.onClearCart,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod? _selectedPaymentMethod = PaymentMethod.cash;
  String? _editableShippingAddress;

  @override
  void initState() {
    super.initState();
    _editableShippingAddress = widget.shippingAddress;
  }

  Future<void> _clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
    widget.onClearCart();
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> _placeOrder(BuildContext context) async {
    final userId = await _getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không tìm thấy userId')),
      );
      return;
    }

    try {
      final profile = await ApiClient().getProfile(userId);
      final shippingAddressFromApi = profile.address?.toString() ?? "Không có thông tin địa chỉ";

      final orderDetailRequests = widget.cart.map((product) {
        return OrderDetailRequest(
          productId: product['id'] ?? 0,
          quantity: product['quantity'] ?? 1,
        );
      }).toList();

      String paymentStatus = '';
      if (_selectedPaymentMethod == PaymentMethod.cash) {
        paymentStatus = "Thanh toán khi nhận hàng";
      } else if (_selectedPaymentMethod == PaymentMethod.vnpay) {
        paymentStatus = "Thanh toán qua VNPay";
      } else if (_selectedPaymentMethod == PaymentMethod.bank) {
        paymentStatus = "Thanh toán qua ngân hàng";
      }
      print('Status trước khi gửi API: $paymentStatus');

      final createOrderRequest = CreateOrderRequest(
        userId: userId,
        totalPrice: widget.totalPrice,
        shippingAddress: _editableShippingAddress ?? shippingAddressFromApi,
        notes: widget.note?.isNotEmpty == true ? widget.note : null,
        orderDetails: orderDetailRequests,
        Status: paymentStatus,
      );

      await ApiClient().createOrder(createOrderRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đơn hàng đã được đặt thành công!')),
      );
      Navigator.of(context).pop();
      widget.onClearCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu đơn hàng: $e')),
      );
    }
  }

  void _confirmOrder(BuildContext context) async {
    if (_selectedPaymentMethod == PaymentMethod.cash) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Xác nhận đặt hàng'),
            content: const Text('Bạn có chắc chắn muốn đặt hàng không?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Có'),
                onPressed: () async {
                  await _placeOrder(context);
                  _clearCart();
                  Navigator.of(context).pop();
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
    } else {
      String methodName = _selectedPaymentMethod == PaymentMethod.vnpay
          ? 'VNPay'
          : 'Ngân hàng';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phương thức $methodName chưa được hỗ trợ.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> paymentMethods = [
      {'name': 'Tiền mặt', 'icon': Icons.money, 'value': PaymentMethod.cash},
      {'name': 'VNPay', 'icon': Icons.qr_code, 'value': PaymentMethod.vnpay},
      {'name': 'Ngân hàng', 'icon': Icons.account_balance, 'value': PaymentMethod.bank},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận đơn hàng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh sách sản phẩm:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
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
                    subtitle: Text(
                      '${product['finalPrice'].toStringAsFixed(3)} VNĐ x ${product['quantity']}',
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                const Text(
                  'Địa chỉ giao hàng:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _editableShippingAddress = value; // Lưu địa chỉ mới vào biến cục bộ
                      });
                    },
                    decoration: InputDecoration(
                      hintText: _editableShippingAddress ?? 'Nhập địa chỉ giao hàng', // Hiển thị gợi ý hoặc địa chỉ hiện tại
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.note != null && widget.note!.isNotEmpty)
              Text(
                'Ghi chú: ${widget.note}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.totalPrice.toStringAsFixed(3)} VNĐ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Chọn phương thức thanh toán:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: RadioListTile<PaymentMethod>(
                      title: Row(
                        children: [
                          Icon(
                            method['icon'],
                            size: 40,
                            color: Colors.teal,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            method['name'],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      value: method['value'],
                      groupValue: _selectedPaymentMethod,
                      onChanged: (PaymentMethod? value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                      activeColor: Colors.teal,
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => _confirmOrder(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Center(
                child: Text('Xác nhận đặt hàng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}