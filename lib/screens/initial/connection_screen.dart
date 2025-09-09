// connection_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/screens/initial/finished_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _ble = FlutterReactiveBle();

  // Use o mesmo SERVICE_UUID do seu Raspberry Pi
  final _serviceUuid = Uuid.parse("12345678-1234-5678-1234-56789abcdef0");
  final _charUuid = Uuid.parse("12345678-1234-5678-1234-56789abcdef1");

  final Map<String, DiscoveredDevice> _devices = {}; // deviceId -> DiscoveredDevice
  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connSub;
  String? _connectedDeviceId;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScanIfPermitted();
  }

  @override
  void dispose() {
    _stopScan();
    _disconnect();
    super.dispose();
  }

  Future<void> _startScanIfPermitted() async {
    final ok = await _ensurePermissions();
    if (!ok) return;
    _startScan();
  }

  Future<bool> _ensurePermissions() async {
    // permission_handler pode ter enums atualizados; lidamos por plataforma.
    if (Platform.isAndroid) {
      // Android 12+ requer BLUETOOTH_SCAN & BLUETOOTH_CONNECT runtime
      final androidInfo = await Permission.bluetoothScan.status;
      // Pedir as permissões juntas:
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetooth,
      ].request();

      // Em Android < 12, você pode precisar de location
      if (await Permission.location.status.isDenied) {
        await Permission.location.request();
      }

      // Considera permissões OK se ao menos bluetoothConnect e bluetoothScan estiverem granted
      return (statuses[Permission.bluetoothScan]?.isGranted ?? false) ||
          (statuses[Permission.bluetooth]?.isGranted ?? false) ||
          (statuses[Permission.bluetoothConnect]?.isGranted ?? false);
    } else if (Platform.isIOS) {
      // iOS mostra prompt automaticamente em operações BLE; pedir location não usual
      return true;
    } else {
      return true;
    }
  }

  void _startScan() {
    _devices.clear();
    setState(() { _isScanning = true; });

    // Scan filtrado por service UUID — assim só aparecem dispositivos que anunciam esse serviço.
    _scanSub = _ble.scanForDevices(withServices: [_serviceUuid], scanMode: ScanMode.lowLatency)
        .listen((device) {
      // device.id, device.name, device.rssi, device.serviceData ...
      // Opcional: também filtrar por nome exato:
      // if (device.name != null && device.name == 'SonorisRPi') { ... }
      _devices[device.id] = device;
      setState(() {});
    }, onError: (err) {
      debugPrint('Scan error: $err');
      setState(() { _isScanning = false; });
    });

    // opcional: parar scan automático depois de X segundos
    Future.delayed(const Duration(seconds: 20), () {
      _stopScan();
    });
  }

  void _stopScan() {
    _scanSub?.cancel();
    _scanSub = null;
    setState(() { _isScanning = false; });
  }

  Future<void> _connectAndStart(DiscoveredDevice device) async {
    _stopScan();
    await _disconnect();

    _connSub = _ble.connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(seconds: 20),
    ).listen((update) async {
      debugPrint('Connection state: ${update.connectionState}');

      if (update.connectionState == DeviceConnectionState.connected) {
        _connectedDeviceId = device.id;
        setState(() {});

        try {
          // 1. ESPERE A DESCOBERTA DE SERVIÇOS TERMINAR
          await _ble.discoverAllServices(device.id);
          debugPrint('Serviços para ${device.id} descobertos!');

          // 2. AGORA PODE ESCREVER COM SEGURANÇA
          final q = QualifiedCharacteristic(
            deviceId: device.id,
            serviceId: _serviceUuid,
            characteristicId: _charUuid,
          );

          await _ble.writeCharacteristicWithoutResponse(q, value: utf8.encode("START"));
          debugPrint('Comando "START" enviado com sucesso para ${device.id}');

          // 3. NAVEGUE PARA A PRÓXIMA TELA
          if (mounted) {
            // Use um nome de rota válido para seu projeto. Ex: '/finished'
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FinishedScreen()),
            );
          }
        } catch (e) {
          debugPrint('ERRO durante a descoberta ou escrita: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao comunicar com o dispositivo: $e')),
            );
          }
          // Se algo der errado aqui, é uma boa ideia desconectar.
          _disconnect();
        }
        // --- FIM DA CORREÇÃO ---

      } else if (update.connectionState == DeviceConnectionState.disconnected) {
        if (_connectedDeviceId == device.id) {
          _connectedDeviceId = null;
          setState(() {});
        }
      }
    }, onError: (error) {
      debugPrint('Erro de conexão: $error');
    });
  }

  Future<void> _disconnect() async {
    if (_connSub != null) {
      try {
        // enviar STOP se ainda tivermos device conectado antes de desconectar
        if (_connectedDeviceId != null) {
          final q = QualifiedCharacteristic(
            deviceId: _connectedDeviceId!,
            serviceId: _serviceUuid,
            characteristicId: _charUuid,
          );
          try {
            await _ble.writeCharacteristicWithoutResponse(q, value: utf8.encode("STOP"));
          } catch (e) {
            debugPrint('Erro ao enviar STOP: $e');
          }
        }
      } catch (_) {}
      await _connSub?.cancel();
      _connSub = null;
      _connectedDeviceId = null;
      setState(() {});
    }
  }

  Widget _buildDeviceTile(DiscoveredDevice d) {
    final connected = d.id == _connectedDeviceId;
    return ListTile(
      leading: SizedBox(width: 36, child: Image.asset('assets/images/Icon.png')),
      title: Text(d.name.isNotEmpty ? d.name : 'Dispositivo sem nome', style: AppTextStyles.body),
      subtitle: Text(d.id, style: AppTextStyles.bodySmall),
      trailing: connected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : ElevatedButton(
        onPressed: () => _connectAndStart(d),
        child: const Text('Conectar'),
      ),
    );
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
        iconTheme: const IconThemeData(
          color: AppColors.blue500,
        ),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Pareamento', style: AppTextStyles.h3.copyWith(color: AppColors.blue500)),
            const SizedBox(height: 6),
            Text('Selecione seu dispositivo Sonoris (apenas dispositivos compatíveis serão mostrados):', style: AppTextStyles.bold),
            const SizedBox(height: 12),
            Row(
              children: [
                CustomButton(
                  text: _isScanning ? 'Parar scan' : 'Procurar dispositivos',
                  fullWidth: false,
                  onPressed: _isScanning ? _stopScan : _startScanIfPermitted,
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // refresh quick
                    if (!_isScanning) _startScanIfPermitted();
                  },
                  child: const Text('Atualizar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _devices.isEmpty
                  ? Center(child: Text(_isScanning ? 'Procurando dispositivos...' : 'Nenhum dispositivo encontrado', style: AppTextStyles.body))
                  : ListView(
                children: _devices.values.map((d) => _buildDeviceTile(d)).toList(),
              ),
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: 'Continuar sem parear (apenas para teste)',
              fullWidth: true,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/main');
              },
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
