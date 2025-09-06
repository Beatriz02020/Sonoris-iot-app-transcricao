import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/screens/initial/connection_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

// TODO: Só entrar nessa página quando o bluetooth estiver desativado

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
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
        title: const Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 55.0, horizontal: 38),
        child: Column(
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
                    'assets/images/Bluetooth.png',
                    fit: BoxFit.contain, // mantém o aspecto original
                  ),
                ),
                Column(
                  spacing: 2,
                  children: [
                    Text(
                      'Ative o Bluetooth',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.blue500,
                      ),
                    ),
                    Text(
                      'O dispositivo requer uma conexão Bluetooth com seu celular',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bold,
                    ),
                  ],
                ),
              ],
            ),
            CustomButton(
              text: 'Habilitar o Bluetooth',
              fullWidth: true,
              onPressed: (/*TODO: Ativar o bluetooth*/) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConnectionScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
