import 'package:flutter/material.dart';
import 'package:martfury/src/view/widget/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'category_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'product_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final Widget? productScreen;
  const MainScreen({
    super.key, 
    this.initialIndex = 0,
    this.productScreen,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    if (mounted) {
      setState(() {
        _screens.clear();
        _screens.addAll([
          const HomeScreen(),
          const CategoryScreen(),
          widget.productScreen ?? const ProductScreen(),
          const CartScreen(),
          const ProfileScreen(),
        ]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_screens.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
