import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/AnswerCategoryButton.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/screens/initial/bluetooth_screen.dart';
import 'package:sonoris/screens/initial/language_screen.dart';
import 'package:sonoris/screens/initial/signup_screen.dart';
import 'package:sonoris/screens/main/home/answer_category_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({super.key});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
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
        title: const Text('Respostas Rápidas'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10, // original (55)
          bottom: 30,
        ),
        child: Column(
          spacing: 4,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Texto explicando como funciona as respostas rápidas',
                    style: AppTextStyles.body.copyWith(color: AppColors.gray700),
                  ),
                  Text(
                    'Categorias',
                    style: AppTextStyles.bold.copyWith(color: AppColors.blue600),
                  ),
                ],
              ),
            ),

            Column(
              spacing: 10,
              children: [
                AnswerCategoryButton(
                  title: 'Positivas',
                  answerAmount: '4 respostas',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/answers/category');
                  },
                ),
                AnswerCategoryButton(
                  title: 'Negativas',
                  answerAmount: '3 respostas',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/answers/category');
                  },
                ),
                AnswerCategoryButton(
                  title: 'Neutras',
                  answerAmount: '5 respostas',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/answers/category');
                  },
                ),
                AnswerCategoryButton(
                  title: 'Perguntas',
                  answerAmount: '12 respostas',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/answers/category');
                  },
                ),

                CustomButton(
                  icon: Icons.add,
                  text:  'Adicionar Categoria',
                  fullWidth: true,
                  onPressed: () {
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
