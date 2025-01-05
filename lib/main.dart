import 'package:flutter/material.dart';
import 'package:fb88/screens/ProductScreen.dart';
import 'package:fb88/screens/SearchScreen.dart';
import 'package:fb88/screens/CartScreen.dart';
import 'package:fb88/screens/ProfileScreen.dart';
import 'package:fb88/screens/LoginScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isLoggedIn = true;

  List<dynamic> _cart = [];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ProductScreen(onAddToCart: _addToCart, cart: _cart),
      SearchScreen(onAddToCart: _addToCart),
      CartScreen(cart: _cart),
      ProfileScreen(onLoginSuccess: _updateLoginStatus),
    ];
  }
  void _addToCart(dynamic product) {
    setState(() {
      final existingProduct = _cart.firstWhere(
            (item) => item['id'] == product['id'],
        orElse: () => null,
      );
      if (existingProduct != null) {
        existingProduct['quantity'] += 1;
      } else {
        product['quantity'] = 1;
        _cart.add(product);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} đã được thêm vào giỏ hàng!')),
    );
  }


  void _onTabTapped(int index) async {
    if (index == 3 && !_isLoggedIn) {
      bool? loginSuccess = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(onLoginSuccess: _updateLoginStatus),
        ),
      );

      if (loginSuccess == true) {
        setState(() {
          _currentIndex = 0;
          _isLoggedIn = true;
        });
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _updateLoginStatus(bool status) {
    setState(() {
      _isLoggedIn = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang Chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Tìm kiếm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Giỏ Hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Hồ Sơ',
          ),
        ],
      ),
    );
  }
}
