import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customDivider.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../components/messageBubble.dart';

class SavedChatScreen extends StatefulWidget {
  const SavedChatScreen({super.key});

  @override
  State<SavedChatScreen> createState() => _SavedChatScreenState();
}

class _SavedChatScreenState extends State<SavedChatScreen> {
  // TODO Descobrir um jeito melhor de trocar a cor quando entrar nessa página
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: AppColors.white100,
          systemNavigationBarColor: AppColors.white100,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white100,
        iconTheme: const IconThemeData(color: AppColors.gray900),
        toolbarHeight: 75,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading:
            false, // desativa o ícone de voltar automático
        titleTextStyle: AppTextStyles.bold.copyWith(color: AppColors.gray900),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => {Navigator.of(context).pushNamed('/')},
                ),
                Stack(
                  children: [
                    Image.asset(
                      height: 53,
                      width: 53,
                      'assets/images/icons/Reuniao.png',
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: -4,
                      left: 25,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: Image.asset('assets/images/icons/Estrela.png'),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Workshop de Criatividade'),
                    Text(
                      '06/07/2025, 14:00 - 17:30',
                      style: AppTextStyles.light.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(Icons.more_vert, color: AppColors.gray900),
          ],
        ),
      ),
      // TODO terminar isso
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: 24,
          top: 20,
          right: 24,
          bottom: 20,
        ),
        decoration: BoxDecoration(color: AppColors.white100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text("Deletar"), Text("Editar"), Text("Favorito")],
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 12, // (55)
              bottom: 30,
            ),
            child: Column(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // chat
                Messagebubble(texto: 'Texto', horario: '17:29:59'),
                Messagebubble(texto: 'Texto', horario: '17:29:59'),
                Messagebubble(
                  texto: 'Texto',
                  horario: '17:29:59',
                  isBlue: true,
                ),
                Messagebubble(texto: 'Texto', horario: '17:29:59'),
                Messagebubble(texto: 'Texto', horario: '17:29:59'),
                Messagebubble(texto: 'Texto', horario: '17:29:59'),
                Messagebubble(
                  texto: 'Texto',
                  horario: '17:29:59',
                  isBlue: true,
                ),
                Messagebubble(
                  texto: 'Texto',
                  horario: '17:29:59',
                  isBlue: true,
                ),

                // descrição
                CustomDivider(),
                Text(
                  'DescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescrição',
                  style: AppTextStyles.body.copyWith(color: AppColors.gray700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
