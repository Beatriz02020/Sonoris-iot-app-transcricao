import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/screens/connection_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

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
      Center(
        child:
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 55.0, horizontal: 50),
          child:
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 1),
            Column(
              spacing: 14,
                children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: ClipRRect(
                            child: Image.asset('assets/images/Logo.png'),
                          ),
                        ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Bem-vindo ao aplicativo',
                          style: AppTextStyles.h3.copyWith(color: AppColors.blue500),
                        ),
                        Text('Escolha como deseja começar',
                            style: AppTextStyles.bold,
                        ),
                      ],
                    ),
                ],
              ), CustomButton(
                    text: 'Conectar dispositivo',
                    fullWidth: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConectionScreen(),
                        ),
                      );
                    },
                  ),
          ],
        ),
        ),
      ),
    );
  }
}
