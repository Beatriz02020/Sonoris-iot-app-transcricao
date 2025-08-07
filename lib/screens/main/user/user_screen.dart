import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customTextField.dart';
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
                Container(
                  color: AppColors.blue200,
                  width: double.infinity,
                  height: 180,
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/images/BannerPerfil.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/Avatar.jpg'),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 30,
                right: 30,
                top: 55,
                bottom: 30,
              ),
              child: Column(
                spacing: 38,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 12,
                    children: [
                      Text(
                        'Nicole Rodrigues',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.blue950,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nome',
                            style: AppTextStyles.bold.copyWith(
                              color: AppColors.gray900,
                            ),
                          ),
                          CustomTextField(
                            hintText: 'Nicole Rodrigues',
                            fullWidth: true,
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data de Nascimento',
                            style: AppTextStyles.bold.copyWith(
                              color: AppColors.gray900,
                            ),
                          ),
                          CustomTextField(
                            hintText: '09/11/2006',
                            fullWidth: true,
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: AppTextStyles.bold.copyWith(
                              color: AppColors.gray900,
                            ),
                          ),
                          CustomTextField(
                            hintText: 'Nicole@Rodrigues.com',
                            fullWidth: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CustomButton(
                        text: 'Salvar',
                        fullWidth: true,
                        onPressed: () {},
                      ),

                      CustomButton(
                        color: AppColors.rose500,
                        text: 'Sair',
                        fullWidth: true,
                        onPressed: () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushReplacementNamed('/initial');
                        },
                      ),
                    ],
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
