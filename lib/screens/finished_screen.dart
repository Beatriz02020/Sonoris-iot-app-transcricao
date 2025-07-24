import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/screens/bluetooth_screen.dart';
import 'package:sonoris/screens/language_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

// TODO arrumar essa página

class FinishedScreen extends StatelessWidget {
  const FinishedScreen({super.key});

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
                    'assets/images/Checkmark.png',
                    fit: BoxFit.contain, // mantém o aspecto original
                  ),
                ),
                Column(
                  spacing: 2,
                  children: [
                    Text('Dispositivo Configurado',
                      style: AppTextStyles.h3.copyWith(color: AppColors.blue500),
                    ),
                    Text('Para utilizar o dispositivo é necessario uma conta Sonoris',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bold,
                    ),
                  ],
                ),
              ],
            ),
        Column(
          spacing: 2,
          children: [
            CustomButton(
              text: 'Cadastro',
              fullWidth: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageScreen(),
                  ),
                );
              },
            ),
            CustomButton(
              text: 'Login',
              outlined: true,
              fullWidth: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageScreen(),
                  ),
                );
              },
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }
}
