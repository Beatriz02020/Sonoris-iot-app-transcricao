import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/components/customBottomNav.dart';
import 'package:sonoris/components/quickActionsButton.dart';
import 'package:sonoris/screens/initial/bluetooth_screen.dart';
import 'package:sonoris/screens/initial/language_screen.dart';
import 'package:sonoris/screens/main/device/device_screen.dart';
import 'package:sonoris/screens/main/home/answer_screen.dart';
import 'package:sonoris/screens/main/home/captions_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// TODO faze o backend desta pagina

class _HomeScreenState extends State<HomeScreen> {
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
      /*appBar: AppBar(
        backgroundColor: AppColors.white100,
        iconTheme: const IconThemeData(
          color: AppColors.blue500,
        ),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text(
            'Titulo da pagina'
        ),
      ),*/
      body:
      Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 55, bottom: 30),
        child:
        Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // nome e foto do usuário
            Row(
                spacing: 10,
                children: [
                  CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage('assets/images/Avatar.png'),
                  ),
                  Text('Olá, Nicole', style: AppTextStyles.h4,),
                  ]
            ),

            // card contendo informações do dispositivo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blue950,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // logo e nome do dispositivo
                      Row(
                          spacing: 5,
                          children: [
                            SizedBox(
                              width: 45,
                              child: Image.asset(
                                'assets/images/Logo.png',
                                fit: BoxFit.contain, // mantém o aspecto original
                              ),
                            ),
                            Text('Sonoris v1.0', style: AppTextStyles.bold.copyWith(color: AppColors.white100)),
                          ]
                      ),

                      // bateria do dispositivo
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bateria', style: AppTextStyles.h4.copyWith(color: AppColors.blue200)),
                          Text('100%', style: AppTextStyles.h3.copyWith(color: AppColors.white100))
                        ],
                      )
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // quantidade de conversas
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Conversas', style: AppTextStyles.h4.copyWith(color: AppColors.blue200)),
                          Text('185', style: AppTextStyles.h3.copyWith(color: AppColors.white100))
                        ],
                      ),

                      // tempo ativo no app
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tempo Ativo', style: AppTextStyles.h4.copyWith(color: AppColors.blue200)),
                          Text('1230h', style: AppTextStyles.h3.copyWith(color: AppColors.white100))
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),

            // ações rápidas
            Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ações rápidas', style: AppTextStyles.body,),

                Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // navegação utilizando container
                    QuickActionsButton(icon: 'RespostasRapidas', text: 'Respostas rápidas', onPressed: AnswerScreen()),
                    QuickActionsButton(icon: 'CustomizarLegendas', text: 'Customizar legendas', onPressed: CaptionsScreen()),
                    QuickActionsButton(icon: 'ConfigurarDispositivo', text: 'Configurar dispositivo', onPressed: DeviceScreen()),
                  ],
                )
              ],
            )






            // conversas não salvas

          ],
        ),
      ),
    );
  }
}
