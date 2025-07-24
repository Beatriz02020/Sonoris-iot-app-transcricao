import 'package:flutter/material.dart';
import 'package:sonoris/components/customBottomNav.dart';
import '../screens/main/home_screen.dart';
import '../screens/main/saved_chats_screen.dart';
import '../screens/main/device_screen.dart';
import '../screens/main/user_screen.dart';


class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    SavedChatsScreen(),
    DeviceScreen(),
    UserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
