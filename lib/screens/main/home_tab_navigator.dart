import 'package:flutter/material.dart';
import 'package:sonoris/screens/main/home/answer_category_screen.dart';
import 'package:sonoris/screens/main/home/answer_screen.dart';
import 'package:sonoris/screens/main/home/captions_screen.dart';
import 'package:sonoris/screens/main/home/home_screen.dart';
import 'package:sonoris/screens/main/home/saving_chat_screen.dart';
import 'package:sonoris/screens/main/home/unsaved_chat_screen.dart';
import 'package:sonoris/screens/main/home/unsaved_chats_screen.dart';
import 'package:sonoris/screens/tab_navigator_observer.dart';

class HomeTabNavigator extends StatelessWidget {
  final Function(bool) setBottomNavVisibility;
  final GlobalKey<NavigatorState> navigatorKey;

  const HomeTabNavigator({
    required this.setBottomNavVisibility,
    required this.navigatorKey,
    super.key,
  });

  void _handleRouteChange(String? routeName) {
    late bool showBottomNav;

    if (routeName == '/unsavedchats/chat') {
      showBottomNav = false;
    } else if (routeName == '/unsavedchats/chat/saving') {
      showBottomNav = false;
    } else if (routeName == '/') {
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
          case '/answers':
            page = const AnswerScreen();
            break;
          case '/answers/category':
            page = const AnswerCategoryScreen(categoriaId: '',);
            break;
          case '/captions':
            page = const CaptionsScreen();
            break;
          case '/unsavedchats':
            page = const UnsavedChatsScreen();
            break;
          case '/unsavedchats/chat':
            page = const UnsavedChatScreen();
            break;
          case '/unsavedchats/chat/saving':
            page = const SavingChatScreen();
            break;
          case '/':
          default:
            page = const HomeScreen();
        }

        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }
}
