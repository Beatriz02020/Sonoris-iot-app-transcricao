import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/chatSelect.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../components/customTextField.dart';

class UnsavedChatsScreen extends StatefulWidget {
  const UnsavedChatsScreen({super.key});

  @override
  State<UnsavedChatsScreen> createState() => _UnsavedChatsScreenState();
}

class _UnsavedChatsScreenState extends State<UnsavedChatsScreen> {
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
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.blue700),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue700),
        title: const Text('Conversas Não Salvas'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 10, // original (55)
              bottom: 30,
            ),
            child: Column(
              spacing: 15,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // texto do começo da página
                Text('As conversas que não forem salvas serão deletadas automaticamente após 1 semana', style: AppTextStyles.body),

                // input de pesquisa
                CustomTextField(hintText: 'Pesquisar', isSearch: true, fullWidth: true,),

                // conversas
                Column(
                  spacing: 12,
                  children: [
                    ChatSelect(nome: 'Conversa_04_07_25_8h', data: '04/07/2025', horarioInicial: '08:30', horarioFinal: '11:30'),
                    ChatSelect(nome: 'Conversa_03_07_25_10h', data: '03/07/2025', horarioInicial: '10:00', horarioFinal: '13:00'),
                    ChatSelect(nome: 'Conversa_02_07_25_9h', data: '02/07/2025', horarioInicial: '09:00', horarioFinal: '12:00'),
                    ChatSelect(nome: 'Conversa_04_07_25_8h', data: '04/07/2025', horarioInicial: '08:30', horarioFinal: '11:30'),
                    ChatSelect(nome: 'Conversa_03_07_25_10h', data: '03/07/2025', horarioInicial: '10:00', horarioFinal: '13:00'),
                    ChatSelect(nome: 'Conversa_02_07_25_9h', data: '02/07/2025', horarioInicial: '09:00', horarioFinal: '12:00'),
                    ChatSelect(nome: 'Conversa_04_07_25_8h', data: '04/07/2025', horarioInicial: '08:30', horarioFinal: '11:30'),
                    ChatSelect(nome: 'Conversa_03_07_25_10h', data: '03/07/2025', horarioInicial: '10:00', horarioFinal: '13:00'),
                    ChatSelect(nome: 'Conversa_02_07_25_9h', data: '02/07/2025', horarioInicial: '09:00', horarioFinal: '12:00'),
                  ],
                ),
              ],
            ),
          ),
        ],),
    );
  }
}
