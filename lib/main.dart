import 'package:flutter/material.dart';
import 'package:sonoris/components/bottomNavigationBar.dart';
import 'package:sonoris/screens/initial/initial_screen.dart';

// TODO arrumar botão de voltar saindo do aplicativo
// TODO consertar o icone e tela de inicio do aplicativo
// TODO organizar pasta de imagens
// TODO finalizar ReadMe
// TODO Fazer responsividade do aplicativo
// TODO verificar os ToDos

// ======= BACKEND =======
// TODO Pareamento de dispositivo                             | Beatriz
// TODO Modo de funcionamento                                 | (DISPOSITIVO)
// TODO Lingua desejada                                       | (DISPOSITIVO)
// TODO Cadastro                                              | Beatriz
// TODO Login                                                 | Beatriz
// TODO Editar dispositivo                                    | (DISPOSITIVO)
// TODO Editar perfil                                         | Amanda
// TODO Adicionar categoria de respostas rápidas              | Amanda
// TODO Botao de pesquisar e filtrar conversas                | Beatriz
// TODO Apresentar lista de conversas salvas e não salvas     | (DISPOSITIVO)
// TODO Customizar legenda                                    | (DISPOSITIVO)
// TODO Adicionar respostas a categoria de respostas rápidas  | Amanda
// TODO Chat de conversas funcional                           | (DISPOSITIVO)
// TODO Salvar conversas                                      | Amanda

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
