import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.cart});

  final List<dynamic> cart;

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Đảm bảo mọi sản phẩm đều có thuộc tính 'quantity'
    for (var product in widget.cart) {
      if (product['quantity'] == null || product['quantity'] <= 0) {
        product['quantity'] = 1; // Gán giá trị mặc định là 1
      }
    }
  }

  // Hàm tính tổng tiền
  double _calculateTotalPrice() {
    return widget.cart.fold(
      0.0,
          (sum, product) => sum + (product['finalPrice'] * product['quantity']),
    );
  }

  // Hàm tăng số lượng
  void _increaseQuantity(int index) {
    setState(() {
      // Chỉ tăng số lượng cho sản phẩm tại vị trí `index`
      widget.cart[index]['quantity'] += 1;
    });
  }



  // Hàm giảm số lượng
  void _decreaseQuantity(int index) {
    setState(() {
      if (widget.cart[index]['quantity'] > 1) {
        widget.cart[index]['quantity'] -= 1; // Chỉ giảm nếu lớn hơn 1
      }
    });
  }



  // Hàm xóa sản phẩm khỏi giỏ hàng
  void _removeFromCart(int index) {
    setState(() {
      widget.cart.removeAt(index);
    });
  }

  // Hàm xử lý thanh toán
  void _checkout() {
    if (widget.cart.isNotEmpty) {
      // Xử lý logic thanh toán tại đây
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanh toán thành công!')),
      );
      setState(() {
        widget.cart.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giỏ hàng trống!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: Column(
        children: [
          // Danh sách sản phẩm trong giỏ hàng
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

          // Phần tổng tiền và nút thanh toán
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Column(
              children: [
                Row(
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
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _checkout,
                  child: const Text('Thanh toán'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    textStyle: const TextStyle(fontSize: 16),
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
