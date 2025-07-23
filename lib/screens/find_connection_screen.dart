import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

// TODO arrumar essa página

class FindConnectionScreen extends StatefulWidget {
  const FindConnectionScreen({super.key});

  @override
  State<FindConnectionScreen> createState() => _FindConnectionScreenState();
}

class _FindConnectionScreenState extends State<FindConnectionScreen> {
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
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 20),
              child: SizedBox(
                width: 250,
                height: 250,
                child: ClipRRect(child: Image.asset('assets/images/Logo.png')),
              ),
            ),
            Text('Pareamento',
              style: AppTextStyles.h3.copyWith(color: AppColors.blue500),
            ),
            Text('Selecione seu dispositivo:',
              style: AppTextStyles.bold,
            ),
            Container(color: Colors.black12, width: 330, height: 100),
          ],
        ),
      ),
    );
  }
}
