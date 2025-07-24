import 'package:flutter/material.dart';
import 'package:sonoris/components/customBottomNav.dart';
import 'package:sonoris/screens/main/device_tab_navigator.dart';
import 'package:sonoris/screens/main/home_tab_navigator.dart';
import 'package:sonoris/screens/main/saved_chats_tab_navigator.dart';
import 'package:sonoris/screens/main/user_tab_navigator.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  bool _showBottomNav = true;

  final List<Widget> _pages = [];

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();

    _pages.addAll([
      HomeTabNavigator(
        navigatorKey: _navigatorKeys[0],
        setBottomNavVisibility: _setBottomNavVisibility,
      ),
      SavedChatsTabNavigator(
        navigatorKey: _navigatorKeys[1],
        setBottomNavVisibility: _setBottomNavVisibility,
      ),
      DeviceTabNavigator(
        navigatorKey: _navigatorKeys[2],
        setBottomNavVisibility: _setBottomNavVisibility,
      ),
      UserTabNavigator(
        navigatorKey: _navigatorKeys[3],
        setBottomNavVisibility: _setBottomNavVisibility,
      ),
    ]);
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _showBottomNav = true; // Sempre mostra ao mudar de aba
    });
  }

  void _setBottomNavVisibility(bool visible) {
    setState(() {
      _showBottomNav = visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _showBottomNav
          ? CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      )
          : null,
    );
  }
}


