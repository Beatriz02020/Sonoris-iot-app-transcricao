import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/screens/initial/finished_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// TODO: Implementar a lógica de conexão com o dispositivo Sonoris

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  Future<bool> getPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await Permission.bluetoothScan.status;

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
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.white100,
        systemNavigationBarColor: AppColors.blue500,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.white100,
      appBar: AppBar(
        backgroundColor: AppColors.white100,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.blue500),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text(''),
      ),
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
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    'Pareamento',
                    style: AppTextStyles.h3.copyWith(color: AppColors.blue500),
                  ),
                  Text('Selecione seu dispositivo:', style: AppTextStyles.bold),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                StreamBuilder<bool>(
                  stream: FlutterBluePlus.isScanning,
                  initialData: false,
                  builder: (c, snapshot) {
                    if (snapshot.data!) {
                      return CustomButton(
                        onPressed: () => FlutterBluePlus.stopScan(),
                        text: 'Parar',
                      );
                    } else {
                      return CustomButton(
                        onPressed:
                            () => FlutterBluePlus.startScan(
                              timeout: const Duration(seconds: 25),
                            ),
                        text: 'Procurar',
                      );
                    }
                  },
                ),
                Column(
                  children: [
                    StreamBuilder<List<BluetoothDevice>>(
                      stream: Stream.periodic(const Duration(seconds:10))
                          .asyncMap((_) => FlutterBluePlus.connectedDevices),
                      initialData: const [],
                      builder: (c, snapshot){
                        snapshot.data.toString();
                        return Column(
                          children: snapshot.data!.map((d) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(d.platformName,style: TextStyle(color: Color(0xFFEDEDED)),),
                                  leading: Icon(Icons.devices,color: Color(0xFFEDEDED).withOpacity(0.3),),
                                  trailing: StreamBuilder<BluetoothConnectionState>(
                                    stream: d.connectionState,
                                    initialData: BluetoothConnectionState.disconnected,
                                    builder: (c, snapshot) {
                                      bool con = snapshot.data == BluetoothConnectionState.connected;
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(color: con?Colors.green:Colors.red),
                                                borderRadius: BorderRadius.all(Radius.circular(8))
                                            )
                                        ),
                                        onPressed: () {Navigator.of(context).pop(SelectedDevice(d,1));}
                                        ,
                                        child:  Text('Connect',style: TextStyle(color: con?Colors.green:Colors.red),),
                                      );
                                    },
                                  ),
                                ),
                                Divider()
                              ],
                            );
                          })
                              .toList(),
                        );
                      },
                    ),
                    StreamBuilder<List<ScanResult>>(
                      stream: FlutterBluePlus.scanResults,
                      initialData: const [],
                      builder: (c, snapshot) {
                        List<ScanResult> scanresults = snapshot.data!;
                        List<ScanResult> templist = [];
                        for (var element in scanresults) {
                          if (element.device.platformName != "") {
                            templist.add(element);
                          }
                        }

                        return SizedBox(
                          height: 190,
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
                                          templist[index].device.platformName,
                                          style: AppTextStyles.body,
                                        ),
                                      ],
                                    ),
                                    CustomButton(
                                      text: "Conectar",
                                      onPressed: () async {
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
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
