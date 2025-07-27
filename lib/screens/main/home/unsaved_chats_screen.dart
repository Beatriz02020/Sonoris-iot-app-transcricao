import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class UnsavedChatsScreen extends StatefulWidget {
  const UnsavedChatsScreen({super.key});

  @override
  State<UnsavedChatsScreen> createState() => _UnsavedChatsScreenState();
}

class _UnsavedChatsScreenState extends State<UnsavedChatsScreen> {
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.blue500),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text('Conversas Não Salvas'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 30,
          right: 30,
          top: 55,
          bottom: 30,
        ),
        child: Column(
          spacing: 4,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conversas Não Salvas', style: AppTextStyles.body),
            CustomButton(
              text: 'Conversa Não Salva',
              fullWidth: true,
              onPressed: () {
                Navigator.of(context).pushNamed('/unsavedchats/chat');
              },
            ),
          ],
        ),
      ),
    );
  }
}
