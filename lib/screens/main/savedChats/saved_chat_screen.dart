import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customDivider.dart';
import 'package:sonoris/screens/initial/bluetooth_screen.dart';
import 'package:sonoris/screens/initial/language_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../components/messageBubble.dart';

class SavedChatScreen extends StatefulWidget {
  const SavedChatScreen({super.key});

  @override
  State<SavedChatScreen> createState() => _SavedChatScreenState();
}

class _SavedChatScreenState extends State<SavedChatScreen> {
  // TODO mudar para branco quando tiver nessa página ( e mudar de volta qnd voltar )
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.background,
        systemNavigationBarColor: AppColors.blue500,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white100,
        iconTheme: const IconThemeData(color: AppColors.gray900),

        // image
        titleTextStyle: AppTextStyles.bold.copyWith(color: AppColors.gray900),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 10,
              children: [
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
                        decoration: BoxDecoration(
                        ),
                        child:  Image.asset(
                          'assets/images/icons/Estrela.png',
                        ),
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
                      style: AppTextStyles.light.copyWith(color: AppColors.gray500),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.more_vert, color: AppColors.gray900),
          ],
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
                Messagebubble(texto: 'Texto', horario: '17:29:59', isBlue: true),
                Messagebubble(texto: 'Texto', horario: '17:29:59'),
                Messagebubble(texto: 'Texto', horario: '17:29:59'),
                Messagebubble(texto: 'Texto', horario: '17:29:59'),
                Messagebubble(texto: 'Texto', horario: '17:29:59', isBlue: true),
                Messagebubble(texto: 'Texto', horario: '17:29:59', isBlue: true),

                // descrição
                CustomDivider(),
                Text('DescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescriçãoDescrição', style: AppTextStyles.body.copyWith(color: AppColors.gray700)),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
