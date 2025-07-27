import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:sonoris/components/bottomNavigationBar.dart';

// TODO arrumar botão de voltar saindo do aplicativo

void main() {
  runApp(const SonorisApp());
}

class SonorisApp extends StatelessWidget {
  const SonorisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sonoris App',
      home: Scaffold(
        // TODO trocar isso por um toast em vez de snackbar
        body: DoubleBackToCloseApp(
          snackBar: const SnackBar(content: Text('Aperte voltar novamente para sair')),
          child: BottomNav(),
        ),
      ),
    );
  }
}
