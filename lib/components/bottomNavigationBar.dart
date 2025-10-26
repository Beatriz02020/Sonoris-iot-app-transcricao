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

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    // Cria os navegadores de cada aba uma única vez para manter o histórico
    _tabs = [
      HomeTabNavigator(
        key: UniqueKey(),
        navigatorKey: _navigatorKeys[0],
        setBottomNavVisibility: _setBottomNavVisibility,
      ),
      SavedChatsTabNavigator(
        key: UniqueKey(),
        navigatorKey: _navigatorKeys[1],
        setBottomNavVisibility: _setBottomNavVisibility,
      ),
      DeviceTabNavigator(
        key: UniqueKey(),
        navigatorKey: _navigatorKeys[2],
        setBottomNavVisibility: _setBottomNavVisibility,
      ),
      UserTabNavigator(
        key: UniqueKey(),
        navigatorKey: _navigatorKeys[3],
        setBottomNavVisibility: _setBottomNavVisibility,
      ),
    ];
  }

  void switchTab(int index) {
    _onItemTapped(index);
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      final nav = _navigatorKeys[index].currentState;
      if (nav != null && nav.canPop()) {
        nav.popUntil((route) => route.isFirst);
      }
      return;
    }

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
    final currentNavigator = _navigatorKeys[_selectedIndex].currentState;
    final bool canCurrentTabPop = currentNavigator?.canPop() ?? false;
    final bool allowSystemPop = _selectedIndex == 0 && !canCurrentTabPop;

    return PopScope(
      canPop: allowSystemPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // o sistema já processou o pop (vai sair do app)

        final nav = _navigatorKeys[_selectedIndex].currentState;
        // Tenta voltar dentro da pilha da aba atual
        if (nav != null && await nav.maybePop()) {
          return;
        }

        // Se estamos na raiz de uma aba diferente da primeira,
        // apenas troca para a primeira aba.
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
            _showBottomNav = true;
          });
          return;
        }
        // Caso contrário (primeira aba na raiz), allowSystemPop == true
        // e o sistema fará o pop (fechar app) em uma próxima tentativa.
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _tabs),
        bottomNavigationBar:
            _showBottomNav
                ? CustomBottomNavBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                )
                : null,
      ),
    );
  }
}
