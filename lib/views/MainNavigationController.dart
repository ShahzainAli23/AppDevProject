import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'options_screen.dart';
import 'ActiveOrdersScreen.dart';
import 'order_history_screen.dart';

class MainNavigationController extends StatefulWidget {
  final bool isGuest;
  const MainNavigationController({super.key, required this.isGuest});

  @override
  State<MainNavigationController> createState() =>
      _MainNavigationControllerState();
}

class _MainNavigationControllerState extends State<MainNavigationController> {
  int _currentIndex = 2;
  final PageController _pageController = PageController(initialPage: 2);

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const ActiveOrdersScreen(),
      CartScreen(isGuest: widget.isGuest),
      const HomeScreen(),
      const OrderHistoryScreen(),
      OptionsScreen(isGuest: widget.isGuest),
    ];
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFF9A825),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, cartProvider, _) {
                return Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (cartProvider.items.isNotEmpty)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cartProvider.items.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.more_vert),
            label: 'Options',
          ),
        ],
      ),
    );
  }
}
