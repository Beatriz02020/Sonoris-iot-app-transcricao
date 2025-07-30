import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.blue500, // cor dos ícones (ex: seta de voltar)
        ),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text('Cadastro'),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 38,
              right: 38,
              top: 0,
              bottom: 55,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 1),
                  Column(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Image.asset(
                          'assets/images/User.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      CustomTextField(hintText: 'Nome', fullWidth: true),
                      CustomTextField(
                        hintText: 'Data de Nascimento',
                        fullWidth: true,
                      ),
                      CustomTextField(hintText: 'Email', fullWidth: true),
                      CustomTextField(hintText: 'Senha', fullWidth: true),
                    ],
                  ),
                  CustomButton(
                    text: 'Cadastrar-se',
                    fullWidth: true,
                    onPressed: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushReplacementNamed('/main');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
