import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/AnswerCategoryButton.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/screens/initial/bluetooth_screen.dart';
import 'package:sonoris/screens/initial/language_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class AnswerCategoryScreen extends StatefulWidget {
  const AnswerCategoryScreen({super.key});

  @override
  State<AnswerCategoryScreen> createState() => _AnswerCategoryScreenState();
}

class _AnswerCategoryScreenState extends State<AnswerCategoryScreen> {
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
        title: const Text('Positivas'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10, // original (55)
          bottom: 30,
        ),
        child:
        Column(
            spacing: 15,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                        icon: Icons.edit,
                        iconSize: 16,
                        text: 'Renomear',
                        onPressed: (){}),
                    CustomButton(
                        icon: Icons.close,
                        iconSize: 16,
                        color: AppColors.rose500,
                        text: 'Deletar Categoria',
                        onPressed: (){})
                  ]
              ),
              Text(
                'Respostas',
                style: AppTextStyles.bold.copyWith(color: AppColors.blue600),
              ),
              Column(
                spacing: 10,
                children: [
                  AnswerCategoryButton(
                    icon: Icons.close,
                    title: 'Sim',
                    onPressed: () {
                    },
                  ),AnswerCategoryButton(
                    icon: Icons.close,
                    title: 'Por favor',
                    onPressed: () {
                    },
                  ),
                  AnswerCategoryButton(
                    icon: Icons.close,
                    title: 'Adoraria',
                    onPressed: () {
                    },
                  ),
                  AnswerCategoryButton(
                    icon: Icons.close,
                    title: 'Claro',
                    onPressed: () {
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

            ]
        ),
      ),
    );
  }
}
