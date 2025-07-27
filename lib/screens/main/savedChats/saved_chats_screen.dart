import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/chatSelect.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/screens/initial/bluetooth_screen.dart';
import 'package:sonoris/screens/initial/language_screen.dart';
import 'package:sonoris/screens/main/savedChats/saved_chat_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../components/customTextField.dart';

class SavedChatsScreen extends StatefulWidget {
  const SavedChatsScreen({super.key});

  @override
  State<SavedChatsScreen> createState() => _SavedChatsScreenState();
}

class _SavedChatsScreenState extends State<SavedChatsScreen> {
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
        //iconTheme: const IconThemeData(color: AppColors.blue700,),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue700),
        title: const Text('Conversas Salvas'),
      ),

      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 30, // original (55)
              bottom: 30,
            ),
            child: Column(
              spacing: 15,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // input de pesquisa
                CustomTextField(
                  hintText: 'Pesquisar',
                  isSearch: true,
                  fullWidth: true,
                ),

                // filtros
                Text('Filtrar por', style: AppTextStyles.body),

                // conversas não salvas
                Row(
                  children: [
                    Row(
                      children: [
                        Text('Conversas Não Salvas')
                      ],
                    ),
                    Row(
                      children: [
                        Text('3'),
                        Image.asset(
                          'assets/images/icons/Estrela.png',
                        ),
                      ],
                    )
                  ],
                ),


                // conversas
                Text('Conversas', style: AppTextStyles.body),

                ChatSelect(nome: 'Reuniao SoftSkills', data: '02/07/2025', horarioInicial: '09:00', horarioFinal: '12:00', image: 'Teams', favorito: true, descricao: 'DescriçãoDescriçãoDescriçasdsada',),
                ChatSelect(nome: 'Workshop de Criatividade', data: '02/07/2025', horarioInicial: '09:00', horarioFinal: '12:00', image: 'Reuniao', favorito: true, descricao: 'DescriçãoDescriçãoDescriçasdsada',),
                ChatSelect(nome: 'Treinamento de Liderança', data: '02/07/2025', horarioInicial: '09:00', horarioFinal: '12:00', image: 'Trabalho', descricao: 'DescriçãoDescriçãoDescriçasdsada',),
                ChatSelect(nome: 'Conversa_01_07_25_13h', data: '02/07/2025', horarioInicial: '09:00', horarioFinal: '12:00', image: 'Outros',),

                CustomButton(
                  text: 'Conversa Salva',
                  fullWidth: true,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/chat');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
