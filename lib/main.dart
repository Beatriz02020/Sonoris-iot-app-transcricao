import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sonoris/components/bottomNavigationBar.dart';
import 'package:sonoris/screens/initial/initial_screen.dart';

import 'firebase_options.dart';

// TODO arrumar botão de voltar saindo do aplicativo
// TODO consertar o icone e tela de inicio do aplicativo
// TODO organizar pasta de imagens
// TODO finalizar ReadMe
// TODO Fazer responsividade do aplicativo
// TODO verificar os ToDos

// ======= BACKEND =======
// TODO Pareamento de dispositivo                             | (DISPOSITIVO)
// TODO Modo de funcionamento                                 |
// TODO Cadastro                                              | Beatriz - FEITO
// TODO Login                                                 | Beatriz - FEITO
// TODO Editar dispositivo                                    | (DISPOSITIVO)
// TODO Editar perfil                                         | Amanda - FEITO
// TODO Adicionar categoria de respostas rápidas              | Amanda - FEITO
// TODO Botao de pesquisar e filtrar conversas                | Beatriz
// TODO Apresentar lista de conversas salvas e não salvas     |
// TODO Customizar legenda                                    |
// TODO Adicionar respostas a categoria de respostas rápidas  | Amanda - FEITO
// TODO Chat de conversas funcional                           |
// TODO Salvar conversas                                      | Amanda

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
      title: 'Sonoris App',
      initialRoute: '/initial',
      routes: {
        '/initial': (context) => const InitialScreen(),
        '/main': (context) => const BottomNav(),
      },
    );
  }
}
