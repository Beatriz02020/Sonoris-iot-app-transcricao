import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/screens/initial/bluetooth_screen.dart';
import 'package:sonoris/screens/initial/login_screen.dart';
import 'package:sonoris/screens/initial/signup_screen.dart';
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 55.0, horizontal: 38),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 1),
            Column(
              spacing: 20,
              children: [
                SizedBox(
                  width: 200,
                  child: Image.asset(
                    'assets/images/Logo.png',
                    fit: BoxFit.contain, // mantém o aspecto original
                  ),
                ),
                Column(
                  spacing: 2,
                  children: [
                    Text(
                      'Bem-vindo ao aplicativo',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.blue500,
                      ),
                    ),
                    Text(
                      'Escolha como deseja começar',
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
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
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
                      MaterialPageRoute(builder: (context) => LoginScreen()),
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
