import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/button.dart';
import 'package:sonoris/components/text_field.dart';
import 'package:sonoris/screens/initial/bluetooth_screen.dart';
import 'package:sonoris/screens/initial/language_screen.dart';
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
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 320,
                height: 230,
                child: Image.asset('assets/images/SonorisFisico.png'),
              ),
              Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        width: 350,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.blue950,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Sonoris v1.23.9',
                              style: AppTextStyles.bold.copyWith(
                                color: AppColors.white100,
                              ),
                            ),
                            Text(
                              'Conectado',
                              style: AppTextStyles.bold.copyWith(
                                color: AppColors.green500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bateria',
                                    style: AppTextStyles.bold.copyWith(
                                      color: AppColors.blue200,
                                    ),
                                  ),
                                  Text(
                                    '57%',
                                    style: AppTextStyles.h4.copyWith(
                                      color: AppColors.white100,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bateria',
                                    style: AppTextStyles.bold.copyWith(
                                      color: AppColors.blue200,
                                    ),
                                  ),
                                  Text(
                                    '57%',
                                    style: AppTextStyles.h4.copyWith(
                                      color: AppColors.white100,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bateria',
                                    style: AppTextStyles.bold.copyWith(
                                      color: AppColors.blue200,
                                    ),
                                  ),
                                  Text(
                                    '57%',
                                    style: AppTextStyles.h4.copyWith(
                                      color: AppColors.white100,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 15,
              bottom: 30,
            ),
            child: Column(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nome do Dispositivo',
                  style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
                ),
                SizedBox(
                  width: 330,
                  child: CustomTextField(hintText: 'Sonoris v1.23.9'),
                ),
                SizedBox(height: 15),
                Text(
                  'Modo de funcionamento',
                  style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
                ),
                SizedBox(
                  width: 330,
                  child: CustomTextField(
                    isDropdown: true,
                    dropdownOptions: [
                      'Transcrição + Respostas Rápidas',
                      'Apenas Transcrição',
                      'Apenas Respostas Rápidas',
                    ],
                    selectedValue: 'Transcrição + Respostas Rápidas',
                    onChanged: (value) {
                      print('Selecionado: $value');
                    },
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Línguas',
                  style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
                ),
                Row(
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
                      side: BorderSide(
                        color: AppColors.blue500,
                        width: 2,
                      ),
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
                      side: BorderSide(
                        color: AppColors.blue500,
                        width: 2,
                      ),
                    ),
                    Text(
                      'Inglês',
                      style: AppTextStyles.bold.copyWith(
                        color: AppColors.gray700,
                      ),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Entrar em Standby após',
                      style: AppTextStyles.bold.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Slider(
                      value: _standbyValue,
                      min: 1,
                      max: 60,
                      divisions: 59,
                      activeColor: AppColors.blue500,
                      onChanged: (value) {
                        setState(() {
                          _standbyValue = value;
                        });
                      },
                    ),
                    SizedBox(height: 2),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '${_standbyValue.round()} minutos sem fala',
                        style: AppTextStyles.medium.copyWith(
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10), // Espaço entre blocos
                // 2. Tempo entre conversas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tempo entre conversas',
                      style: AppTextStyles.bold.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Slider(
                      value: _conversaValue,
                      min: 1,
                      max: 60,
                      divisions: 59,
                      activeColor: AppColors.blue500,
                      onChanged: (value) {
                        setState(() {
                          _conversaValue = value;
                        });
                      },
                    ),
                    SizedBox(height: 2),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '${_conversaValue.round()} minutos',
                        style: AppTextStyles.medium.copyWith(
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Deletar conversas não salvas após',
                      style: AppTextStyles.bold.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    Slider(
                      value: _deletarValue,
                      min: 1,
                      max: 100,
                      divisions: 99,
                      activeColor: AppColors.blue500,
                      onChanged: (value) {
                        setState(() {
                          _deletarValue = value;
                        });
                      },
                    ),

                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '${_deletarValue.round()} dias',
                        style: AppTextStyles.medium.copyWith(
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
