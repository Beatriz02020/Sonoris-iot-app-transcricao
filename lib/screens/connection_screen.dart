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
      appBar: AppBar(),
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 10),
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: ClipRRect(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              label: Icon(
                                Icons.bluetooth,
                                size: 110,
                                color: Colors.white,
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                side: BorderSide(width: 0),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child:
                        Text('Ative o Bluetooth',
                        style: AppTextStyles.h3.copyWith(color: AppColors.blue500),
                      ),
                      ),
                      SizedBox(
                        width: 290,
                        child: Text('O dispositivo requer uma conexão Bluetooth com seu celular',
                          style: AppTextStyles.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: CustomButton(
                    text: 'Habilitar o Bluetooth',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FindConnectionScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
