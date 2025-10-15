import 'package:flutter/material.dart';
import 'package:sonoris/components/customBottomNav.dart';
import 'package:sonoris/screens/main/device_tab_navigator.dart';
import 'package:sonoris/screens/main/home_tab_navigator.dart';
import 'package:sonoris/screens/main/saved_chats_tab_navigator.dart';
import 'package:sonoris/screens/main/user_tab_navigator.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  // Adicione esta linha para permitir acesso ao state de fora
  static _BottomNavState? of(BuildContext context) =>
      context.findAncestorStateOfType<_BottomNavState>();

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  bool _showBottomNav = true;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  late final List<Widget Function()> _pageFactories = [
    () => HomeTabNavigator(
      key: UniqueKey(),
      navigatorKey: _navigatorKeys[0],
      setBottomNavVisibility: _setBottomNavVisibility,
    ),
    () => SavedChatsTabNavigator(
      key: UniqueKey(),
      navigatorKey: _navigatorKeys[1],
      setBottomNavVisibility: _setBottomNavVisibility,
    ),
    () => DeviceTabNavigator(
      key: UniqueKey(),
      navigatorKey: _navigatorKeys[2],
      setBottomNavVisibility: _setBottomNavVisibility,
    ),
    () => UserTabNavigator(
      key: UniqueKey(),
      navigatorKey: _navigatorKeys[3],
      setBottomNavVisibility: _setBottomNavVisibility,
    ),
  ];

  void switchTab(int index) {
    _onItemTapped(index);
  }

  // Função para gerar a página com uma UniqueKey
  Widget _getPage(int index) {
    return _pageFactories[index]();
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
      // Use apenas a página atual, com UniqueKey
      body: _getPage(_selectedIndex),
      bottomNavigationBar:
          _showBottomNav
              ? CustomBottomNavBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              )
              : null,
    );
  }
}
