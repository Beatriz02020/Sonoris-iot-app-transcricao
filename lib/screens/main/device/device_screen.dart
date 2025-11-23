import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sonoris/components/customSlider.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../components/customButton.dart';
import '../../../services/bluetooth_manager.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final BluetoothManager _manager =
      BluetoothManager(); // Certifique-se de inicializar o BluetoothManager
  BluetoothConnectionState _connState = BluetoothConnectionState.disconnected;
  StreamSubscription<BluetoothConnectionState>? _connStateSub;
  StreamSubscription<BluetoothDevice?>? _deviceSub;
  bool _wasConnected = false; // Para rastrear se já esteve conectado

  @override
  void initState() {
    super.initState();

    // Assine o estado de conexão para atualizar a UI
    _connStateSub = _manager.connectionStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _connState = state;
      });

      // Notifica o usuário quando o dispositivo for desconectado
      if (state == BluetoothConnectionState.disconnected && _wasConnected) {
        _wasConnected = false;
      } else if (state == BluetoothConnectionState.connected) {
        _wasConnected = true;
      }
    });

    // Assine o stream do dispositivo para atualizar quando conectar/desconectar
    _deviceSub = _manager.deviceStream.listen((device) {
      if (!mounted) return;
      setState(() {
        // Força atualização da UI quando o device mudar
      });
    });
  }

  // Adicione estes estados para os sliders:
  double _conversaValue = 5;
  double _deletarValue = 7;
  bool _isConnecting = false; // Controla o overlay de conexão

  @override
  void dispose() {
    _connStateSub?.cancel();
    _deviceSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isThisConnected =
        _manager.connectedDevice != null &&
        _connState == BluetoothConnectionState.connected;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.background,
        systemNavigationBarColor: AppColors.blue500,
      ),
    );

    return Stack(
      children: [
        Scaffold(
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
                              // nome do dispositivo
                              Text(
                                'Dispositivo Sonoris',
                                style: AppTextStyles.bold.copyWith(
                                  color: AppColors.white100,
                                ),
                              ),

                              // bateria do dispositivo
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 6,
                                children: [
                                  Text(
                                    isThisConnected
                                        ? 'Conectado'
                                        : 'Desconectado',
                                    style: AppTextStyles.body.copyWith(
                                      color:
                                          isThisConnected
                                              ? AppColors.teal500
                                              : AppColors.rose500,
                                    ),
                                  ),
                                  Container(
                                    height: 9,
                                    width: 9,
                                    decoration: BoxDecoration(
                                      color:
                                          isThisConnected
                                              ? AppColors.teal500
                                              : AppColors.rose500,
                                      borderRadius: BorderRadius.circular(100),
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
                                    'Conversas',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.blue200,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    '0',
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
                                    '0h',
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
                    isThisConnected
                        ? Column(
                          children: [
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
                                  hintText: 'Nome do dispositivo',
                                  fullWidth: true,
                                ),
                              ],
                            ),

                            /*
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Modo de funcionamento',
                              style: AppTextStyles.bold.copyWith(
                                color: AppColors.gray900,
                              ),
                            ),
                            CustomSelect(
                              options: [
                                'Transcrição + Respostas Rápidas',
                                'Apenas Transcrição',
                              ],
                              value: 'Transcrição + Respostas Rápidas',
                              onChanged: (value) {},
                            ),
                          ],
                        ),


                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      'Línguas',
                      style: AppTextStyles.bold.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        SizedBox(
                          height: 24.0,
                          width: 24.0,
                          child: Checkbox(
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
                      spacing: 10,
                      children: [
                        SizedBox(
                          height: 24.0,
                          width: 24.0,
                          child: Checkbox(
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
                          onChanged:
                              (value) => setState(() => _standbyValue = value),
                          valueLabel:
                              '${_standbyValue.round()} minutos sem fala',
                        ),

                        CustomSlider(
                          label: 'Tempo entre conversas',
                          value: _conversaValue,
                          min: 1,
                          max: 60,
                          onChanged:
                              (value) => setState(() => _conversaValue = value),
                          valueLabel: '${_conversaValue.round()} minutos',
                        ),
*/
                            CustomSlider(
                              label: 'Deletar conversas não salvas após',
                              value: _deletarValue,
                              min: 1,
                              max: 30,
                              onChanged:
                                  (value) =>
                                      setState(() => _deletarValue = value),
                              valueLabel: '${_deletarValue.round()} dias',
                            ),
                          ],
                        )
                        : Column(
                          spacing: 4,
                          children: [
                            Text(
                              'Selecione seu dispositivo:',
                              style: AppTextStyles.bold,
                            ),
                            Column(
                              spacing: 6,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamBuilder<bool>(
                                  stream: FlutterBluePlus.isScanning,
                                  initialData: false,
                                  builder: (c, snapshot) {
                                    final isScanning = snapshot.data ?? false;
                                    return CustomButton(
                                      onPressed: () {
                                        if (isScanning) {
                                          FlutterBluePlus.stopScan();
                                          // Atualiza UI para remover dispositivos da lista
                                          setState(() {});
                                        } else {
                                          FlutterBluePlus.startScan(
                                            timeout: const Duration(
                                              seconds: 25,
                                            ),
                                          );
                                        }
                                      },
                                      text: isScanning ? 'Parar' : 'Procurar',
                                      isLoading: isScanning,
                                    );
                                  },
                                ),
                                Column(
                                  children: [
                                    StreamBuilder<bool>(
                                      stream: FlutterBluePlus.isScanning,
                                      initialData: false,
                                      builder: (context, scanningSnapshot) {
                                        final isScanning =
                                            scanningSnapshot.data ?? false;

                                        return StreamBuilder<List<ScanResult>>(
                                          stream: FlutterBluePlus.scanResults,
                                          initialData: const [],
                                          builder: (c, snapshot) {
                                            List<ScanResult> scanresults =
                                                snapshot.data!;
                                            const String SERVICE_UUID =
                                                "12345678-1234-5678-1234-56789abcdef0";

                                            // Se não está escaneando, limpa a lista
                                            List<ScanResult> templist = [];
                                            if (isScanning) {
                                              for (var element in scanresults) {
                                                // Verifica se tem nome E se tem o SERVICE_UUID correto
                                                final hasCorrectService = element
                                                    .advertisementData
                                                    .serviceUuids
                                                    .any(
                                                      (uuid) =>
                                                          uuid
                                                              .toString()
                                                              .toLowerCase() ==
                                                          SERVICE_UUID
                                                              .toLowerCase(),
                                                    );
                                                if (element
                                                            .device
                                                            .platformName !=
                                                        "" &&
                                                    hasCorrectService) {
                                                  templist.add(element);
                                                }
                                              }
                                            }

                                            return SizedBox(
                                              height: 190,
                                              child: ListView.builder(
                                                itemCount: templist.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 12,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.white100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withAlpha(18),
                                                          blurRadius: 18.5,
                                                          spreadRadius: 1,
                                                          offset: const Offset(
                                                            0,
                                                            6,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 30,
                                                              child: Image.asset(
                                                                'assets/images/Icon.png',
                                                                fit:
                                                                    BoxFit
                                                                        .contain,
                                                              ),
                                                            ),
                                                            Text(
                                                              templist[index]
                                                                  .device
                                                                  .platformName,
                                                              style:
                                                                  AppTextStyles
                                                                      .body,
                                                            ),
                                                          ],
                                                        ),
                                                        CustomButton(
                                                          text: "Conectar",
                                                          onPressed: () async {
                                                            final dev =
                                                                templist[index]
                                                                    .device;

                                                            // Guarda referência do scaffoldMessenger antes do async
                                                            final scaffoldMessenger =
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                );

                                                            // Mostra o overlay
                                                            setState(() {
                                                              _isConnecting =
                                                                  true;
                                                            });

                                                            try {
                                                              await _manager
                                                                  .connect(dev);

                                                              // Fecha o overlay
                                                              if (mounted) {
                                                                setState(() {
                                                                  _isConnecting =
                                                                      false;
                                                                });
                                                              }

                                                              if (!mounted)
                                                                return;

                                                              scaffoldMessenger.showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                    'Conectado com sucesso!',
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                  duration:
                                                                      Duration(
                                                                        seconds:
                                                                            2,
                                                                      ),
                                                                ),
                                                              );

                                                              // Atualizar UI se ainda montado
                                                              if (mounted) {
                                                                setState(() {});
                                                              }
                                                            } catch (e) {
                                                              // Fecha o overlay
                                                              if (mounted) {
                                                                setState(() {
                                                                  _isConnecting =
                                                                      false;
                                                                });
                                                              }

                                                              if (!mounted)
                                                                return;

                                                              scaffoldMessenger.showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Falha ao conectar: ${e.toString()}',
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  duration:
                                                                      const Duration(
                                                                        seconds:
                                                                            4,
                                                                      ),
                                                                ),
                                                              );

                                                              // Garante que a UI seja atualizada após erro
                                                              if (mounted) {
                                                                setState(() {});
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Overlay de conexão
        if (_isConnecting)
          Container(
            color: Colors.black.withAlpha(128),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.blue500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Conectando...',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.blue700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
