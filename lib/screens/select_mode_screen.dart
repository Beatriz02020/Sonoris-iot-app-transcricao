import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/screens/bluetooth_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

// TODO arrumar essa página

class SelectModeScreen extends StatelessWidget {
  const SelectModeScreen({super.key});

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
                    'assets/images/Choice.png',
                    fit: BoxFit.contain, // mantém o aspecto original
                  ),
                ),
                Column(
                  spacing: 2,
                  children: [
                    Text('Modo de funcionamento',
                      style: AppTextStyles.h3.copyWith(color: AppColors.blue500),
                    ),
                    Text('Qual o modo de operação do dispositivo?',
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
              text: 'Transcrição + Respostas Rápidas',
              fullWidth: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BluetoothScreen(),
                  ),
                );
              },
            ),
            CustomButton(
              text: 'Apenas transcrição',
              fullWidth: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BluetoothScreen(),
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
