import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class SavingChatScreen extends StatefulWidget {
  const SavingChatScreen({super.key});

  @override
  State<SavingChatScreen> createState() => _SavingChatScreenState();
}

class _SavingChatScreenState extends State<SavingChatScreen> {
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
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.blue500),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text('Salvar Conversa'),
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
          children: [Text('Salvar Conversa', style: AppTextStyles.body)],
        ),
      ),
    );
  }
}
