import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/components/custom_slider.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool _isCheckedPt = false; // Para Português (Brasileiro)
  bool _isCheckedEn = false; // Para Inglês

  // Adicione estes estados para os sliders:
  double _standbyValue = 5;
  double _conversaValue = 10;
  double _deletarValue = 30;

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
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue700),
        title: const Text('Dispositivo'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 15,
              bottom: 30,
            ),
            child: Column(
              spacing: 18,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 320,
                  height: 230,
                  child: Image.asset('assets/images/SonorisFisico.png'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blue950,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    spacing: 8,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // logo e nome do dispositivo
                          Row(
                            spacing: 8,
                            children: [
                              Text(
                                'Sonoris v1.0',
                                style: AppTextStyles.bold.copyWith(
                                  color: AppColors.white100,
                                ),
                              ),
                            ],
                          ),

                          // bateria do dispositivo
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conectado',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.teal500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 8,
                        children: [
                          // quantidade de conversas
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bateria',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.blue200,
                                  height: 1,
                                ),
                              ),
                              Text(
                                '57%',
                                style: AppTextStyles.bold.copyWith(
                                  color: AppColors.white100,
                                ),
                              ),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conversas',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.blue200,
                                  height: 1,
                                ),
                              ),
                              Text(
                                '185',
                                style: AppTextStyles.bold.copyWith(
                                  color: AppColors.white100,
                                ),
                              ),
                            ],
                          ),

                          // tempo ativo no app
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tempo Ativo',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.blue200,
                                  height: 1,
                                ),
                              ),
                              Text(
                                '1230h',
                                style: AppTextStyles.bold.copyWith(
                                  color: AppColors.white100,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nome do Dispositivo',
                      style: AppTextStyles.bold.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    CustomTextField(
                      hintText: 'Sonoris v1.23.9',
                      fullWidth: true,
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modo de funcionamento',
                      style: AppTextStyles.bold.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    CustomTextField(
                      isDropdown: true,
                      fullWidth: true,
                      dropdownOptions: [
                        'Transcrição + Respostas Rápidas',
                        'Apenas Transcrição',
                      ],
                      selectedValue: 'Transcrição + Respostas Rápidas',
                      onChanged: (value) {},
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Línguas',
                      style: AppTextStyles.bold.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    Row(
                      spacing: 0,
                      children: [
                        Checkbox(
                          value: _isCheckedPt,
                          onChanged: (bool? value) {
                            setState(() {
                              _isCheckedPt = value ?? false;
                            });
                          },
                          activeColor: AppColors.blue500,
                          checkColor: AppColors.white100,
                          side: BorderSide(color: AppColors.blue500, width: 2),
                        ),
                        Text(
                          'Português (Brasileiro)',
                          style: AppTextStyles.bold.copyWith(
                            color: AppColors.gray700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _isCheckedEn,
                          onChanged: (bool? value) {
                            setState(() {
                              _isCheckedEn = value ?? false;
                            });
                          },
                          activeColor: AppColors.blue500,
                          checkColor: AppColors.white100,
                          side: BorderSide(color: AppColors.blue500, width: 2),
                        ),
                        Text(
                          'Inglês',
                          style: AppTextStyles.bold.copyWith(
                            color: AppColors.gray700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                CustomSlider(
                  label: 'Entrar em Standby após',
                  value: _standbyValue,
                  min: 1,
                  max: 60,
                  onChanged: (value) => setState(() => _standbyValue = value),
                  valueLabel: '${_standbyValue.round()} minutos sem fala',
                ),

                CustomSlider(
                  label: 'Tempo entre conversas',
                  value: _conversaValue,
                  min: 1,
                  max: 60,
                  onChanged: (value) => setState(() => _conversaValue = value),
                  valueLabel: '${_conversaValue.round()} minutos',
                ),

                CustomSlider(
                  label: 'Deletar conversas não salvas após',
                  value: _deletarValue,
                  min: 1,
                  max: 100,
                  onChanged: (value) => setState(() => _deletarValue = value),
                  valueLabel: '${_deletarValue.round()} dias',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
