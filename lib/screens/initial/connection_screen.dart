import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customSnackBar.dart';
import 'package:sonoris/screens/initial/finished_screen.dart';
import 'package:sonoris/services/bluetooth_manager.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _manager = BluetoothManager();

  StreamSubscription<BluetoothDevice?>? _deviceSub;
  StreamSubscription<BluetoothConnectionState>? _connStateSub;
  StreamSubscription<String>? _valueSub;

  String _lastValue = '';

  Future<bool> getPermissions() async {
    if (Platform.isAndroid) {
      final statuses =
          await [
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
            Permission.bluetooth,
          ].request();

      if (await Permission.location.status.isDenied) {
        await Permission.location.request();
      }

      return (statuses[Permission.bluetoothScan]?.isGranted ?? false) ||
          (statuses[Permission.bluetooth]?.isGranted ?? false) ||
          (statuses[Permission.bluetoothConnect]?.isGranted ?? false);
    } else if (Platform.isIOS) {
      return true;
    } else {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    getPermissions();

    // assinaturas para atualizar UI (não desconectam o manager)
    _deviceSub = _manager.deviceStream.listen((d) {
      setState(() {});
    });
    _connStateSub = _manager.connectionStateStream.listen((s) {
      setState(() {});
    });
    _valueSub = _manager.valueStream.listen((v) {
      setState(() => _lastValue = v);
    });
  }

  @override
  void dispose() {
    _deviceSub?.cancel();
    _connStateSub?.cancel();
    _valueSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.white100,
        systemNavigationBarColor: AppColors.blue500,
      ),
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white100,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 45.0, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/images/SonorisFisico.png',
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      'Pareamento',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.blue500,
                      ),
                    ),
                    Text(
                      'Selecione seu dispositivo:',
                      style: AppTextStyles.bold,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
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
                              timeout: const Duration(seconds: 25),
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
                          final isScanning = scanningSnapshot.data ?? false;

                          return StreamBuilder<List<ScanResult>>(
                            stream: FlutterBluePlus.scanResults,
                            initialData: const [],
                            builder: (c, snapshot) {
                              List<ScanResult> scanresults = snapshot.data!;
                              // Filtrar apenas dispositivos com SERVICE_UUID correto
                              const String SERVICE_UUID =
                                  "12345678-1234-5678-1234-56789abcdef0";

                              // Se não está escaneando, limpa a lista
                              List<ScanResult> templist = [];

                              if (isScanning) {
                                final Map<String, ScanResult> byId = {};
                                String _displayNameFor(ScanResult r) {
                                  final n = r.device.name.toString();
                                  final pn = r.device.platformName.toString();
                                  if (n.isNotEmpty) return n;
                                  if (pn.isNotEmpty) return pn;
                                  return r.device.id.toString();
                                }

                                for (var r in scanresults) {
                                  // Verifica se o dispositivo anuncia o SERVICE_UUID
                                  final hasCorrectService = r
                                      .advertisementData
                                      .serviceUuids
                                      .any(
                                        (uuid) =>
                                            uuid.toString().toLowerCase() ==
                                            SERVICE_UUID.toLowerCase(),
                                      );

                                  if (!hasCorrectService)
                                    continue; // Pula dispositivos sem o serviço correto

                                  final key = r.device.id.toString();
                                  if (!byId.containsKey(key)) {
                                    byId[key] = r;
                                  } else {
                                    final existing = byId[key]!;
                                    final existingName = _displayNameFor(
                                      existing,
                                    );
                                    final newName = _displayNameFor(r);
                                    if (existingName.isEmpty &&
                                        newName.isNotEmpty) {
                                      byId[key] = r;
                                    }
                                  }
                                }

                                templist = byId.values.toList();
                                templist.sort((a, b) {
                                  final aName = _displayNameFor(a);
                                  final bName = _displayNameFor(b);
                                  final aEmpty = aName.isEmpty;
                                  final bEmpty = bName.isEmpty;
                                  if (aEmpty && !bEmpty) return 1;
                                  if (!aEmpty && bEmpty) return -1;
                                  return aName.compareTo(bName);
                                });
                              }

                              return SizedBox(
                                height: 260,
                                child: ListView.builder(
                                  itemCount: templist.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.white100,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(18),
                                            blurRadius: 18.5,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            spacing: 6,
                                            children: [
                                              // Avatar circular
                                              SizedBox(
                                                width: 30,
                                                child: Image.asset(
                                                  'assets/images/Icon.png',
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              Text(
                                                // Prefer device.name, then platformName, then id as fallback
                                                (templist[index].device.name
                                                        .toString()
                                                        .isNotEmpty)
                                                    ? templist[index]
                                                        .device
                                                        .name
                                                        .toString()
                                                    : (templist[index]
                                                            .device
                                                            .platformName
                                                            .toString()
                                                            .isNotEmpty
                                                        ? templist[index]
                                                            .device
                                                            .platformName
                                                            .toString()
                                                        : templist[index]
                                                            .device
                                                            .id
                                                            .toString()),
                                                style: AppTextStyles.body,
                                              ),
                                            ],
                                          ),
                                          CustomButton(
                                            text: "Conectar",
                                            onPressed: () async {
                                              final dev =
                                                  templist[index].device;

                                              // Guarda referência do context antes do async
                                              final navigator = Navigator.of(
                                                context,
                                              );
                                              final scaffoldMessenger =
                                                  ScaffoldMessenger.of(context);

                                              // mostra loading customizado
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (_) => Center(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              24,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              AppColors
                                                                  .white100,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                    Color
                                                                  >(
                                                                    AppColors
                                                                        .blue500,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              height: 16,
                                                            ),
                                                            Text(
                                                              'Conectando...',
                                                              style: AppTextStyles
                                                                  .body
                                                                  .copyWith(
                                                                    color:
                                                                        AppColors
                                                                            .blue700,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                              );

                                              try {
                                                // conecte e aguarde até o manager ter enviado START
                                                await BluetoothManager()
                                                    .connect(dev);

                                                // Verifica se o widget ainda está montado
                                                if (!mounted) return;

                                                // se chegou aqui, START foi enviado com sucesso -> navega
                                                navigator
                                                    .pop(); // fecha o dialog
                                                navigator.pushReplacement(
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) =>
                                                            const FinishedScreen(),
                                                  ),
                                                );
                                              } catch (e) {
                                                // Verifica se o widget ainda está montado
                                                if (!mounted) return;

                                                if (navigator.canPop()) {
                                                  navigator
                                                      .pop(); // fecha o dialog
                                                }

                                                scaffoldMessenger.showSnackBar(
                                                  CustomSnackBar.error(
                                                    'Falha ao conectar ao dispositivo. Tente novamente.',
                                                  ),
                                                );
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
                  CustomButton(
                    text: "Continuar sem dispositivo",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FinishedScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectedDevice {
  BluetoothDevice? device;
  int? state;

  SelectedDevice(this.device, this.state);
}
