import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/screens/initial/bluetooth_screen.dart';
import 'package:sonoris/screens/initial/language_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.background,
        systemNavigationBarColor: AppColors.blue500,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      /*appBar: AppBar(
        backgroundColor: AppColors.white100,
        iconTheme: const IconThemeData(
          color: AppColors.blue500,
        ),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text(
            'Titulo da pagina'
        ),
      ),*/
      body:
      Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 55, bottom: 30),
        child:
        Column(
          spacing: 4,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Página Principal', style: AppTextStyles.body,),
            CustomButton(
              text: 'Conversas Não Salvas',
              fullWidth: true,
              onPressed: () {
                Navigator.of(context).pushNamed('/unsavedchats');
              },
            ),
            CustomButton(
              text: 'Legenda',
              fullWidth: true,
              onPressed: () {
                Navigator.of(context).pushNamed('/captions');
              },
            ),
            CustomButton(
              text: 'Respostas Rápidas',
              fullWidth: true,
              onPressed: () {
                Navigator.of(context).pushNamed('/answers');
              },
            ),
          ],
        ),
      ),
    );
  }
}
