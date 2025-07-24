import 'package:flutter/widgets.dart';

class TabNavigatorObserver extends NavigatorObserver {
  final Function(String?) onRouteChanged;

  TabNavigatorObserver(this.onRouteChanged);

  @override
  void didPush(Route route, Route? previousRoute) {
    onRouteChanged(route.settings.name);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    onRouteChanged(previousRoute?.settings.name);
  }
}
