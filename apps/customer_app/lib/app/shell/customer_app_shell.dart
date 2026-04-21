import 'package:customer_app/features/cart/pages/cart_page.dart';
import 'package:customer_app/features/store/pages/store_page.dart';
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
      extendBody: true,
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
            selectedIcon: Icons.home_rounded,
            label: 'Home',
            iconOffsetX: 1.1,
          ),
          MBBottomNavItem(
            icon: Icons.storefront_outlined,
            selectedIcon: Icons.storefront_rounded,
            label: 'Store',
            iconOffsetX: 0.8,
          ),
          MBBottomNavItem(
            icon: Icons.chat_bubble_outline_rounded,
            selectedIcon: Icons.chat_bubble_rounded,
            label: 'Chat',
            iconOffsetX: 0.0,
          ),
          MBBottomNavItem(
            icon: Icons.shopping_cart_outlined,
            selectedIcon: Icons.shopping_cart_rounded,
            label: 'Cart',
            iconOffsetX: -0.8,
          ),
          MBBottomNavItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: 'Profile',
            iconOffsetX: -1.6,
          ),
        ],
        onTap: _onTap,
      ),
    );
  }
}
