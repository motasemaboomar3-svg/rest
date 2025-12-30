import 'package:flutter/material.dart';
import 'menu_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _i = 0;
  final _pages = const [MenuScreen(), OrdersScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_i],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'المنيو'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'طلباتي'),
          NavigationDestination(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
