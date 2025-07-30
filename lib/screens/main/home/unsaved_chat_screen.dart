import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../components/arrowCircleButton.dart';
import '../../../components/messageBubble.dart';

class UnsavedChatScreen extends StatefulWidget {
  const UnsavedChatScreen({super.key});

  @override
  State<UnsavedChatScreen> createState() => _UnsavedChatScreenState();
}

class _UnsavedChatScreenState extends State<UnsavedChatScreen> {
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

        titleTextStyle: AppTextStyles.bold.copyWith(color: AppColors.gray900),
        title: Row(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Conversa_04_07_25_8h'),
                  Text(
                    '04/07/2025, 08:30 - 11:30',
                    style: AppTextStyles.light.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
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
                Messagebubble(
                  texto: 'Texto',
                  horario: '17:29:59',
                  isBlue: true,
                ),
                Messagebubble(texto: 'Texto', horario: '17:29:59'),
                Messagebubble(texto: 'Texto', horario: '17:29:59'),
                Messagebubble(texto: 'Texto', horario: '17:29:59'),
                Messagebubble(texto: 'Texto', horario: '17:29:59'),
                Messagebubble(texto: 'Texto', horario: '17:29:59'),
                Messagebubble(
                  texto: 'Texto',
                  horario: '17:29:59',
                  isBlue: true,
                ),

                // TODO fazer esse botao
                // ArrowCircleButton()
              ],

            ),

          ),
        ],
      ),
    );
  }
}
