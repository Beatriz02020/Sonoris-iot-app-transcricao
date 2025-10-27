import 'package:flutter/material.dart';
import 'package:sonoris/models/conversa.dart';
import 'package:sonoris/screens/main/savedChats/editing_chat_screen.dart';
import 'package:sonoris/screens/main/savedChats/saved_chat_screen.dart';

import '../tab_navigator_observer.dart';
import 'savedChats/saved_chats_screen.dart';

class SavedChatsTabNavigator extends StatelessWidget {
  final Function(bool) setBottomNavVisibility;
  final GlobalKey<NavigatorState> navigatorKey;

  const SavedChatsTabNavigator({
    required this.setBottomNavVisibility,
    required this.navigatorKey,
    super.key,
  });

  void _handleRouteChange(String? routeName) {
    late bool showBottomNav;

    if (routeName == '/savedchats/chat' ||
        routeName == '/savedchats/chat/editing') {
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
          case '/savedchats/chat':
            // Recebe a conversa via arguments
            final conversa = settings.arguments as ConversaSalva?;
            if (conversa != null) {
              page = SavedChatScreen(conversa: conversa);
            } else {
              page =
                  const SavedChatsScreen(); // Fallback se não houver conversa
            }
            break;
          case '/savedchats/chat/editing':
            // Recebe a conversa salva para edição
            final conversa = settings.arguments as ConversaSalva?;
            if (conversa != null) {
              page = EditingChatScreen(conversa: conversa);
            } else {
              page = const SavedChatsScreen(); // Fallback
            }
            break;
          case '/':
          default:
            page = const SavedChatsScreen();
        }

        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }
}
