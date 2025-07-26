import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/components/text_field.dart';
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 43),
                  child: Container(
                    color: AppColors.blue200,
                    width: double.infinity,
                    height: 150,
                    child: ClipRRect(
                      child: Image.asset(
                        'assets/images/Banner.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: (MediaQuery.of(context).size.width / 2) - 50,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: AppColors.blue300,
                      border: Border.all(color: AppColors.gray900, width: 2),
                    ),
                    width: 100,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'assets/images/Logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Text(
              'Nome da Pessoa',
              style: AppTextStyles.h3.copyWith(color: AppColors.blue950),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 30,
                right: 30,
                top: 33,
                bottom: 30,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nome',
                    style: AppTextStyles.bold.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                  SizedBox(width: 330, child: CustomTextField()),

                  SizedBox(height: 15),

                  Text(
                    'Data de Nascimento',
                    style: AppTextStyles.bold.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                  SizedBox(width: 330, child: CustomTextField()),

                  SizedBox(height: 15),

                  Text(
                    'Email',
                    style: AppTextStyles.bold.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  SizedBox(
                    width: 330,
                    child: CustomTextField(hintText: 'Nicole@Rodrigues.com'),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Column(
                      children: [
                        CustomButton(
                          width: 330,
                          text: 'Salvar',
                          onPressed: () {},
                        ),

                        CustomButton(
                          color: AppColors.rose600,
                          text: 'Sair',
                          width: 330,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
