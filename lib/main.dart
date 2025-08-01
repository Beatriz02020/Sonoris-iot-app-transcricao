import 'package:flutter/material.dart';
import 'package:sonoris/components/bottomNavigationBar.dart';
import 'package:sonoris/screens/initial/initial_screen.dart';

// TODO arrumar botão de voltar saindo do aplicativo
// TODO concertar o icone e tela de inicio do aplicativo
// TODO finalizar ReadMe
// TODO Fazer responsividade do aplicativo
// TODO fazer o backend

void main() {
  runApp(const SonorisApp());
}

class SonorisApp extends StatelessWidget {
  const SonorisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sonoris App',
      initialRoute: '/main',
      routes: {
        '/initial': (context) => const InitialScreen(),
        '/main': (context) => const BottomNav(),
      },
    );
  }
}
