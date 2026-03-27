import 'package:customer_app/features/cart/pages/cart_page.dart';
import 'package:customer_app/features/categories/pages/categories_page.dart';
import 'package:customer_app/features/chat/pages/chat_page.dart';
import 'package:customer_app/features/home/pages/home_page.dart';
import 'package:customer_app/features/profile/pages/profile_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class CustomerAppShell extends StatefulWidget {
  const CustomerAppShell({super.key});

  @override
  State<CustomerAppShell> createState() => _CustomerAppShellState();
}

class _CustomerAppShellState extends State<CustomerAppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    StorePage(),
    ChatPage(),
    CartPage(),
    ProfilePage(),
  ];

  void _onTap(int index) {
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: kIsWeb
          ? null
          : MBBottomNavBar(
              currentIndex: _currentIndex,
              items: const [
                MBBottomNavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                ),
                MBBottomNavItem(
                  icon: Icons.storefront_outlined,
                  label: 'Store',
                ),
                MBBottomNavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Chat',
                ),
                MBBottomNavItem(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Cart',
                ),
                MBBottomNavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                ),
              ],
              onTap: _onTap,
            ),
    );
  }
}









