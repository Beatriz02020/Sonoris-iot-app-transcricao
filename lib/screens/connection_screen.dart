import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/screens/find_connection_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

// TODO arrumar essa página

class ConectionScreen extends StatefulWidget {
  const ConectionScreen({super.key});

  @override
  State<ConectionScreen> createState() => _ConectionScreenState();
}

class _ConectionScreenState extends State<ConectionScreen> {
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
          'Minha Tela'
        ),
      ),
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
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      child: Image.asset('assets/images/Bluetooth.png'),
                    ),
                  ),
                  Text('Ative o Bluetooth',
                    style: AppTextStyles.h3.copyWith(color: AppColors.blue500),
                  ),
                  Text('O dispositivo requer uma conexão Bluetooth com seu celular',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bold,
                  ),
                ],
              ),
              CustomButton(
                text: 'Habilitar o Bluetooth',
                fullWidth: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FindConnectionScreen(),
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
