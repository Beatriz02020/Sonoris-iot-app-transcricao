import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/components/customSelect.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class SavingChatScreen extends StatefulWidget {
  const SavingChatScreen({super.key});

  @override
  State<SavingChatScreen> createState() => _SavingChatScreenState();
}

class _SavingChatScreenState extends State<SavingChatScreen> {
  int? _selectedCategoryIndex;

  Widget _buildCategoryItem({
    required String assetPath,
    required String label,
    required Color labelColor,
    required int index,
  }) {
    final bool isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryIndex = index),
      child: Column(
        children: [
          Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: AppColors.gray300,
                          blurRadius: 6,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    assetPath,
                    width: 53,
                    height: 53,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isSelected) ...[
                  Positioned.fill(
                    child: ClipOval(
                      child: Container(color: AppColors.gray900.withAlpha(50)),
                    ),
                  ),
                  const Icon(Icons.check, color: Colors.white, size: 45),
                ],
              ],
            ),
          ),
          Text(label, style: AppTextStyles.bold.copyWith(color: labelColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.background,
        systemNavigationBarColor: AppColors.blue500,
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.blue500),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text('Salvar Conversa'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
              SizedBox(
                height: 95,
                child:
                //TODO: Fazer essa listview sair para fora do padding
                ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Favoritos.png',
                          label: 'Favoritos',
                          labelColor: AppColors.amber600,
                          index: 0,
                        ),
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Estudos.png',
                          label: 'Estudos',
                          labelColor: AppColors.blue600,
                          index: 1,
                        ),
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Trabalho.png',
                          label: 'Trabalhos',
                          labelColor: AppColors.teal600,
                          index: 2,
                        ),
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Pessoal.png',
                          label: 'Pessoal',
                          labelColor: AppColors.rose600,
                          index: 3,
                        ),
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Reuniao.png',
                          label: 'Reunião',
                          labelColor: AppColors.green600,
                          index: 4,
                        ),
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Teams.png',
                          label: 'Teams',
                          labelColor: AppColors.indigo600,
                          index: 5,
                        ),
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Outros.png',
                          label: 'Outros',
                          labelColor: AppColors.gray700,
                          index: 6,
                        ),
                        _buildCategoryItem(
                          assetPath: 'assets/images/icons/Customizado.png',
                          label: 'Customizado',
                          labelColor: AppColors.gray700,
                          index: 7,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Text(
                'Nome',
                style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: CustomTextField(),
              ),

              Text(
                'Descrição',
                style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: CustomTextField(
                  hintText: 'Descrição',
                  verticalPadding: 70,
                ),
              ),

              Text(
                'Favorito?',
                style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 45),
                child: CustomSelect(
                  options: ['Sim', 'Não'],
                  value: 'Sim',
                  onChanged: (value) {},
                ),
              ),
              CustomButton(
                text: 'Salvar Conversa',
                fullWidth: true,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
