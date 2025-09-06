import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/colorSelector.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/components/custom_slider.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class CaptionsScreen extends StatefulWidget {
  const CaptionsScreen({super.key});

  @override
  State<CaptionsScreen> createState() => _CaptionsScreenState();
}

class _CaptionsScreenState extends State<CaptionsScreen> {
  Color selectedColorLinha1 = AppColors.blue600;
  Color selectedColorLinha2 = AppColors.white100;

  double _fontSizeValue = 18;
  double _fontBoldValue = 50;
  double _txtSpeedValue = 10;
  double _verticalValue = 1.3;
  double _horizontalValue = 0;

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
        title: const Text('Customizar Legenda'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: 30,
        ),
        child: Column(
          spacing: 25,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // TODO: Mudar o texto de exemplo para refletir as mudanças automaticamente
            Container(
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white100,
                border: Border.all(
                  color: AppColors.blue700,
                  width: 1.5, // stroke width
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Este é um texto de exemplo.\n'
                'As legendas ficarão assim na tela do seu dispositivo.'
                '\n\n Customize do melhor jeito para você',

                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray900,
                  height: 1.3,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cor do texto',
                          style: AppTextStyles.bold.copyWith(
                            color: AppColors.gray900,
                          ),
                        ),

                        Row(
                          children: [
                            SizedBox(
                              height: 60,
                              width: (MediaQuery.of(context).size.width - 60),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  // TODO: adicionar mais cores
                                  ColorSelector(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.gray900,
                                      AppColors.gray700,
                                      AppColors.gray500,
                                      AppColors.white100,
                                      AppColors.blue600,
                                      AppColors.green500,
                                      AppColors.rose600,
                                      AppColors.rose500,
                                    ],
                                    selectedColor: selectedColorLinha1,
                                    enableCustomPicker: true,
                                    onColorSelected: (color) {
                                      setState(
                                        () => selectedColorLinha1 = color,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Cor de fundo',
                          style: AppTextStyles.bold.copyWith(
                            color: AppColors.gray900,
                          ),
                        ),

                        Row(
                          children: [
                            SizedBox(
                              height: 60,
                              width: (MediaQuery.of(context).size.width - 60),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  // TODO: adicionar mais cores
                                  ColorSelector(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.gray900,
                                      AppColors.gray700,
                                      AppColors.gray500,
                                      AppColors.white100,
                                      AppColors.blue600,
                                      AppColors.green500,
                                      AppColors.rose600,
                                      AppColors.rose500,
                                    ],
                                    selectedColor: selectedColorLinha2,
                                    enableCustomPicker: true,
                                    onColorSelected: (color) {
                                      setState(
                                        () => selectedColorLinha2 = color,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Fonte',
                          style: AppTextStyles.bold.copyWith(
                            color: AppColors.gray900,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CustomTextField(
                            isDropdown: true,
                            fullWidth: true,
                            dropdownOptions: ['Inter', 'Comic Sans Ms'],
                            selectedValue: 'Inter',
                            onChanged: (value) {},
                          ),
                        ),

                        CustomSlider(
                          label: 'Tamanho da Fonte',
                          value: _fontSizeValue,
                          min: 1,
                          max: 36,
                          onChanged:
                              (value) => setState(() => _fontSizeValue = value),
                          valueLabel: '${_fontSizeValue.round()}pt',
                        ),

                        CustomSlider(
                          label: 'Grossura da Fonte',
                          value: _fontBoldValue,
                          min: 1,
                          max: 100,
                          onChanged:
                              (value) => setState(() => _fontBoldValue = value),
                        ),

                        CustomSlider(
                          label: 'Velocidade do texto',
                          value: _txtSpeedValue,
                          min: 1,
                          max: 20,
                          onChanged:
                              (value) => setState(() => _txtSpeedValue = value),
                          valueLabel:
                              '${_txtSpeedValue.round()} carácteres por segundo',
                        ),

                        Text(
                          'Animação',
                          style: AppTextStyles.bold.copyWith(
                            color: AppColors.gray900,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CustomTextField(
                            isDropdown: true,
                            fullWidth: true,
                            dropdownOptions: ['Sem Animação', 'Com Animação'],
                            selectedValue: 'Sem Animação',
                            onChanged: (value) {},
                          ),
                        ),

                        CustomSlider(
                          label: 'Tamanho da linha',
                          value: _verticalValue,
                          min: 1,
                          max: 2,
                          onChanged:
                              (value) => setState(() => _verticalValue = value),
                        ),

                        CustomSlider(
                          label: 'Espaçamento horizontal',
                          value: _horizontalValue,
                          min: -10,
                          max: 10,
                          onChanged:
                              (value) =>
                                  setState(() => _horizontalValue = value),
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
