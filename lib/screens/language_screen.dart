import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/screens/bluetooth_screen.dart';
import 'package:sonoris/screens/finished_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.white100,
        systemNavigationBarColor: AppColors.blue500,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.white100,
      appBar: AppBar(
        backgroundColor: AppColors.white100, // cor de fundo da AppBar
        iconTheme: const IconThemeData(
          color: AppColors.blue500, // cor dos ícones (ex: seta de voltar)
        ),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text(
            ''
        ),
      ),
      body:
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 55.0, horizontal: 38),
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 1),
            Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  child: Image.asset(
                    'assets/images/Language.png',
                    fit: BoxFit.contain, // mantém o aspecto original
                  ),
                ),
                Column(
                  spacing: 2,
                  children: [
                    Text('Línguas',
                      style: AppTextStyles.h3.copyWith(color: AppColors.blue500),
                    ),
                    Text('Quais línguas o dispositivo deve reconhecer?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bold,
                    ),
                  ],
                ),
                Column(
                  spacing: 0,
                  children: [
                    Row(
                        spacing: 0,
                        children: [
                          Checkbox(
                            value: true,
                            onChanged: (value) {},
                            activeColor: AppColors.blue500,      // cor da bolinha marcada
                            checkColor: AppColors.white100,      // cor do check (✓)
                          ),
                          Text('Português (Brasileiro)',
                            style: AppTextStyles.bold,
                          ),
                        ],
                  ),
                    Row(
                      spacing: 0,
                      children: [
                        Checkbox(
                          value: false,
                          onChanged: (value) {},
                          activeColor: AppColors.blue500,      // cor da bolinha marcada
                          checkColor: AppColors.white100,
                        ),
                        Text('Inglês',
                          style: AppTextStyles.bold,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            CustomButton(
              text: 'Finalizar configuração',
              fullWidth: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FinishedScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
