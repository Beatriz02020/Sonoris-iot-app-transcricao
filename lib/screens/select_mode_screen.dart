import 'package:flutter/material.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/components/text.dart';

class SelectModeScreen extends StatelessWidget {
  const SelectModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTitle(text: 'Modo de funcionamento'),
            CustomSubtitle(text: 'Qual o modo de operação do dispositivo?'),
            SizedBox(width: 350, child: CustomButton(text: 'Transcrição + Respostas Rápidas', onPressed: (){})),
            SizedBox(width: 350, child: CustomButton(text: 'Apenas Transcrição', onPressed: (){})),
          ],
        ),
      )
    );
  }
}
