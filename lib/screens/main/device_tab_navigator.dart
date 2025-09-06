import 'package:flutter/material.dart';
import 'package:sonoris/screens/tab_navigator_observer.dart';

import 'device/device_screen.dart';

class DeviceTabNavigator extends StatelessWidget {
  final Function(bool) setBottomNavVisibility;
  final GlobalKey<NavigatorState> navigatorKey;

  const DeviceTabNavigator({
    required this.setBottomNavVisibility,
    required this.navigatorKey,
    super.key,
  });

  void _handleRouteChange(String? routeName) {
    late bool showBottomNav;

    if (routeName == '/') {
      showBottomNav = true;
    } else {
      showBottomNav = true;
    }

    // Adia a chamada de setState() até o próximo frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setBottomNavVisibility(showBottomNav);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      observers: [TabNavigatorObserver(_handleRouteChange)],
      onGenerateRoute: (settings) {
        late Widget page;

        switch (settings.name) {
          case '/':
          default:
            page = const DeviceScreen();
        }

        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }
}
