import 'package:fb88/screens/CartScreen.dart';
import 'package:fb88/screens/ProductScreen.dart';
import 'package:fb88/screens/ProfileScreen.dart';
import 'package:fb88/screens/SearchScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Animate Demo',
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
  bool _isLoggedIn = false; // Quản lý trạng thái đăng nhập.
  List<dynamic> _cart = [];
  late final List<Widget> _screens;


  @override
  void initState() {
    super.initState();
    _screens = [
      ProductScreen(onAddToCart: _addToCart, cart: _cart),
      const SearchScreen(),
      CartScreen(cart: _cart),
      ProfileScreen(isLoggedIn: _isLoggedIn),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _updateLoginStatus(bool status) {
    setState(() {
      _isLoggedIn = status;
    });
  }

  void _addToCart(dynamic product) {
    setState(() {
      _cart.add(product);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} đã được thêm vào giỏ hàng!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body sẽ là màn hình hiện tại theo _currentIndex
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




class ScreenThree extends StatelessWidget {
  const ScreenThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: const Center(
        child: Text('This is the Search screen!'),
      ),
    );
  }
}
