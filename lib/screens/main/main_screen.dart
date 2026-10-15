import 'package:flutter/material.dart';

import '../../widgets/common/app_bottom_navigation.dart';
import '../cart/cart_screen.dart';
import '../favorite/favorite_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
    HomeScreen(onCartPressed: () => _onTabSelected(2)),
    const FavoriteScreen(),
    CartScreen(onContinueShopping: () => _onTabSelected(0)),
    const ProfileScreen(),
  ];

  void _onTabSelected(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
