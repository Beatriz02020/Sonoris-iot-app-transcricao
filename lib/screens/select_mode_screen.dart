import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/button.dart';
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
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Modo de funcionamento',
              style: AppTextStyles.h3.copyWith(color: AppColors.blue500),
            ),
            Text('Qual o modo de operação do dispositivo?',
              style: AppTextStyles.bold,
            ),
            SizedBox(width: 350, child: CustomButton(text: 'Transcrição + Respostas Rápidas', onPressed: (){})),
            SizedBox(width: 350, child: CustomButton(text: 'Apenas Transcrição', onPressed: (){})),
          ],
        ),
      )
    );
  }
}
