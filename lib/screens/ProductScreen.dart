import 'package:flutter/material.dart';
import 'package:fb88/screens/CartScreen.dart';
import '../api/api_client.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.onAddToCart, required this.cart});
  final Function(dynamic) onAddToCart;
  final List<dynamic> cart;

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<dynamic> displayedProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    ApiClient.setupInterceptors();
    _getProducts();
  }

  Future<void> _getProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiClient.dio.get(
        "/api/products",
      );

      List<dynamic> products = response.data as List;

      setState(() {
        displayedProducts = products;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(cart: widget.cart), // Truyền cart vào
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: displayedProducts.length,
        itemBuilder: (context, index) {
          final product = displayedProducts[index];
          return ProductItem(
            product: product,
            onAddToCart: () => widget.onAddToCart(product),
          );
        },
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  const ProductItem({super.key, required this.product, required this.onAddToCart});

  final dynamic product;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final double price = product['price'] as double;
    final double finalPrice = product['finalPrice'] as double;
    final double promotionPrice = product['promotionPrice'] as double;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Image.network(
            product['imageUrl'],
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                if (promotionPrice > 0) ...[
                  Text(
                    '${price.toStringAsFixed(3)} VNĐ',
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.purple,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${finalPrice.toStringAsFixed(3)} VNĐ (KM: ${promotionPrice.toStringAsFixed(0)}%)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ]
                else
                  Text(
                    '${finalPrice.toStringAsFixed(3)} VNĐ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.purple,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: onAddToCart,
          ),
        ],
      ),
    );
  }
}
