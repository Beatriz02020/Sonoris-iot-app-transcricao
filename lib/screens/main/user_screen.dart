import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/screens/initial/bluetooth_screen.dart';
import 'package:sonoris/screens/initial/language_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
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
            Text('Página de Perfil', style: AppTextStyles.body,)

          ],
        ),
      ),
    );
  }
}
