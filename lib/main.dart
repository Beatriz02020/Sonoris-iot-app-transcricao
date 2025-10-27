import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sonoris/components/bottomNavigationBar.dart';
import 'package:sonoris/screens/initial/connection_screen.dart';
import 'package:sonoris/screens/initial/initial_screen.dart';

import 'firebase_options.dart';

// TODO arrumar botão de voltar saindo do aplicativo
// TODO consertar o icone e tela de inicio do aplicativo
//TODO: Customizar as mensagens de erro do Firebase no geral

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SonorisApp());
}

class SonorisApp extends StatelessWidget {
  const SonorisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sonoris',
      // Envolve toda a árvore de widgets do app com SafeArea
      builder: (context, child) {
        return SafeArea(
          top: false, // Set to true se quiser evitar também a área do notch
          bottom:
              true, // Evita sobreposição com a barra de navegação do sistema
          child: child ?? const SizedBox.shrink(),
        );
      },
      // Use a propriedade 'home' para definir o widget inicial.
      // Ele vai decidir qual tela mostrar.
      home: const AuthCheck(),

      // Suas outras rotas nomeadas continuam aqui para navegação futura
      routes: {
        '/initial': (context) => const InitialScreen(),
        '/main': (context) => const BottomNav(),
        '/test': (context) => const ConnectionScreen(),
      },
    );
  }
}

// Coloque a classe AuthCheck que criamos acima aqui ou em um arquivo separado
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const BottomNav(); // Usuário logado
        }

        return const InitialScreen(); // Usuário não logado
      },
    );
  }
}
