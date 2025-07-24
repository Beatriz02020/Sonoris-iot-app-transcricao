import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/screens/select_mode_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
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
          padding: const EdgeInsets.symmetric(vertical: 45.0, horizontal: 20),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/images/SonorisFisico.png',
                  fit: BoxFit.contain, // mantém o aspecto original
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 18),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [Text('Pareamento', style: AppTextStyles.h3.copyWith(color: AppColors.blue500),), Text('Selecione seu dispositivo:', style: AppTextStyles.bold,),
                  ],
                ),
              ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white100,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 18.5,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 6,
                      children: [
                        // Avatar circular
                        SizedBox(
                          width: 30,
                          child: Image.asset(
                            'assets/images/Icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          'Dispositivo Sonoris',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                    Icon(
                      Icons.circle_outlined,
                      color: AppColors.blue500,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white100,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 18.5,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 6,
                      children: [
                        // Avatar circular
                        SizedBox(
                          width: 30,
                          child: Image.asset(
                            'assets/images/Icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          'Dispositivo Sonoris',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                    Icon(
                      Icons.circle_outlined,
                      color: AppColors.blue500,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white100,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 18.5,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 6,
                      children: [
                        // Avatar circular
                        SizedBox(
                          width: 30,
                          child: Image.asset(
                            'assets/images/Icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          'Dispositivo Sonoris',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                    Icon(
                      Icons.circle_outlined,
                      color: AppColors.blue500,
                    ),
                  ],
                ),
              ),
              CustomButton(
                text: 'Proxima tela (placeholder)',
                fullWidth: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectModeScreen(),
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
