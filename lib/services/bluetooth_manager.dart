// lib/services/bluetooth_manager.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager {
  // Singleton
  BluetoothManager._internal();
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() => _instance;

  // streams públicos para UI
  final _deviceController = StreamController<BluetoothDevice?>.broadcast();
  final _connectionStateController =
      StreamController<BluetoothConnectionState>.broadcast();
  final _valueController = StreamController<String>.broadcast();

  Stream<BluetoothDevice?> get deviceStream => _deviceController.stream;
  Stream<BluetoothConnectionState> get connectionStateStream =>
      _connectionStateController.stream;
  Stream<String> get valueStream => _valueController.stream;

  // internals
  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<int>>? _charSub;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  // usado para evitar que enviemos START várias vezes por conexão
  bool _processingConnected = false;
  bool _hasSentStart = false;
  DateTime? _lastStartSentAt;

  // completor para quando a UI chama connect() e aguarda handshake (START enviado)
  Completer<void>? _connectCompleter;

  // UUIDs do peripheral
  static const String SERVICE_UUID = "12345678-1234-5678-1234-56789abcdef0";
  static const String CHAR_UUID = "12345678-1234-5678-1234-56789abcdef1";

  /// Conecta ao device. Retorna quando a sequência de discover + (notify se houver) + write("START")
  /// for concluída com sucesso (ou lança erro).
  Future<void> connect(
    BluetoothDevice device, {
    bool autoReconnect = true,
  }) async {
    // se já estamos conectados ao mesmo device e já processamos connected, apenas retorna
    if (_device != null && _device!.id == device.id && !_hasSentStart) {
      // existe o device, mas talvez ainda não tenhamos completado handshake
    }
    // se outro connect está em progresso, aguardamos sua conclusão
    if (_isConnecting) {
      // aguardamos o completor atual, se houver
      if (_connectCompleter != null) {
        return _connectCompleter!.future;
      }
    }

    _isConnecting = true;
    _device = device;
    _deviceController.add(_device);

    // prepara completor para o chamador inicial
    _connectCompleter ??= Completer<void>();

    try {
      // conecta sem autoConnect (evita conflito mtu/autoConnect)
      await device.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 10),
      );
    } catch (e) {
      // se já estava conectado, device.connect pode lançar; permitimos continuar
      debugPrint('device.connect erro/aviso: $e');
    }

    // cancelar subscrição anterior se houver e criar nova
    await _connSub?.cancel();
    _connSub = device.connectionState.listen((state) async {
      _connectionStateController.add(state);

      if (state == BluetoothConnectionState.connected) {
        // quando receber connected, dispara handler (debounced)
        _handleConnected(device, autoReconnect: autoReconnect);
      } else if (state == BluetoothConnectionState.disconnected) {
        // reset flags para próxima conexão
        _hasSentStart = false;
        _processingConnected = false;
        // cancelar stream da char (se houver)
        await _charSub?.cancel();
        _charSub = null;

        // se autoReconnect habilitado, tenta reconectar com backoff
        if (autoReconnect) {
          // backoff simples (poderia ser exponencial)
          await Future.delayed(const Duration(seconds: 2));
          if (_device != null) {
            try {
              // tenta reconectar (chamada recursiva controlada)
              await connect(_device!, autoReconnect: autoReconnect);
            } catch (e) {
              debugPrint('reconnect falhou: $e');
            }
          }
        }
      }
    });

    // retornamos quando o handshake (START) for enviado ou erro
    try {
      return await _connectCompleter!.future;
    } finally {
      // limpamos o completor somente se estiver completo
      if (_connectCompleter != null && _connectCompleter!.isCompleted) {
        _connectCompleter = null;
      }
      _isConnecting = false;
    }
  }

  /// Handler que executa discoverServices, configura notification (se suportado)
  /// e envia START. É garantido que só um handler execute por vez (debounce).
  Future<void> _handleConnected(
    BluetoothDevice device, {
    bool autoReconnect = true,
  }) async {
    if (_processingConnected) {
      debugPrint('Já processando connected — ignorando evento duplicado.');
      return;
    }
    _processingConnected = true;

    try {
      // discover services
      List<BluetoothService> services = await device.discoverServices();
      final service = services.firstWhere(
        (s) => s.uuid.toString().toLowerCase() == SERVICE_UUID.toLowerCase(),
        orElse: () => throw Exception('Serviço $SERVICE_UUID não encontrado'),
      );

      final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString().toLowerCase() == CHAR_UUID.toLowerCase(),
        orElse:
            () => throw Exception('Characteristic $CHAR_UUID não encontrado'),
      );

      _characteristic = characteristic;

      // se a characteristic suporta notify, habilita — senão, pula
      final props = characteristic.properties;
      final supportsNotify = (props.notify) || (props.indicate);
      if (supportsNotify) {
        try {
          await characteristic.setNotifyValue(true);
          // subscreve aos valores
          await _charSub?.cancel();
          _charSub = characteristic.value.listen((bytes) {
            try {
              final s = utf8.decode(bytes);
              _valueController.add(s);
            } catch (_) {
              final s = String.fromCharCodes(bytes);
              _valueController.add(s);
            }
          });
        } catch (e) {
          debugPrint('Erro ao habilitar notify: $e');
          // mas seguimos — talvez o peripheral não use notify
        }
      } else {
        // se não suporta notify, assegure que não exista subscrição antiga
        await _charSub?.cancel();
        _charSub = null;
      }

      // DEBOUNCE & prevenção de envios duplicados:
      // evita reenviar START num intervalo curto
      final now = DateTime.now();
      if (_hasSentStart && _lastStartSentAt != null) {
        final diff = now.difference(_lastStartSentAt!);
        if (diff.inMilliseconds < 800) {
          debugPrint(
            'START já enviado recentemente (${diff.inMilliseconds}ms) — pulando reenvio.',
          );
          // completa o completor caso exista (pois já enviou antes)
          if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
            _connectCompleter!.complete();
          }
          _processingConnected = false;
          return;
        }
      }

      // envia START (escolhe a forma de escrita adequada)
      try {
        await _writeStartToCharacteristic();
        _hasSentStart = true;
        _lastStartSentAt = DateTime.now();
        debugPrint('START enviado com sucesso.');
      } catch (e) {
        debugPrint('Falha ao enviar START: $e');
        // rethrow para informar erro pro completor
        if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
          _connectCompleter!.completeError(e);
        }
        _processingConnected = false;
        return;
      }

      // se chegou até aqui, complete o completor de connection (se existir)
      if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
        _connectCompleter!.complete();
      }
    } catch (e) {
      debugPrint('_handleConnected erro: $e');
      if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
        _connectCompleter!.completeError(e);
      }
    } finally {
      _processingConnected = false;
    }
  }

  Future<void> _writeStartToCharacteristic() async {
    if (_characteristic == null) {
      throw Exception('Characteristic não configurada.');
    }

    final bytes = utf8.encode('START');
    final props = _characteristic!.properties;

    // Para debugging — registra as propriedades
    debugPrint(
      'Characteristic props: write=${props.write}, writeWithoutResponse=${props.writeWithoutResponse}, notify=${props.notify}, indicate=${props.indicate}',
    );

    // Decide métod preferido:
    // preferWithResponse se available, caso contrário prefer withoutResponse.
    final bool canWriteWithResponse = props.write;
    final bool canWriteWithoutResponse = props.writeWithoutResponse;

    if (!canWriteWithResponse && !canWriteWithoutResponse) {
      throw Exception(
        'Characteristic não suporta escrita (nem withResponse nem withoutResponse).',
      );
    }

    // preferir withResponse (se disponível) — mas só tentamos um métod por vez com retries
    final bool tryWithResponseFirst = canWriteWithResponse;

    const int maxAttempts = 3;
    int attempt = 0;
    Exception? lastError;

    while (attempt < maxAttempts) {
      attempt++;
      try {
        if (tryWithResponseFirst) {
          if (canWriteWithResponse) {
            debugPrint('Tentando write withResponse attempt $attempt');
            await _characteristic!.write(bytes, withoutResponse: false);
            return; // sucesso
          } else if (canWriteWithoutResponse) {
            debugPrint(
              'Fallback: tentando write withoutResponse attempt $attempt',
            );
            await _characteristic!.write(bytes, withoutResponse: true);
            return;
          }
        } else {
          // tenta withoutResponse primeiro
          if (canWriteWithoutResponse) {
            debugPrint('Tentando write withoutResponse attempt $attempt');
            await _characteristic!.write(bytes, withoutResponse: true);
            return;
          } else if (canWriteWithResponse) {
            debugPrint(
              'Fallback: tentando write withResponse attempt $attempt',
            );
            await _characteristic!.write(bytes, withoutResponse: false);
            return;
          }
        }
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        debugPrint('write attempt $attempt falhou: $e');
        // se for ultima tentativa, rethrow abaixo
        if (attempt < maxAttempts) {
          // backoff simples
          final delayMs = 150 * (1 << (attempt - 1)); // 150, 300, 600...
          await Future.delayed(Duration(milliseconds: delayMs));
          continue;
        }
      }
    }

    // se chegou aqui, todas as tentativas falharam
    throw lastError ?? Exception('Falha desconhecida ao escrever START');
  }

  /// Escreve texto arbitrário na characteristic. Mantém a lógica de fallback.
  Future<void> writeString(
    String text, {
    bool preferWithResponse = true,
  }) async {
    if (_characteristic == null) {
      throw Exception(
        'Characteristic não configurada (chame connect/discover primeiro).',
      );
    }
    final bytes = utf8.encode(text);
    final props = _characteristic!.properties;

    try {
      if (preferWithResponse && (props.write)) {
        await _characteristic!.write(bytes, withoutResponse: false);
        return;
      }
      if (!preferWithResponse && (props.writeWithoutResponse)) {
        await _characteristic!.write(bytes, withoutResponse: true);
        return;
      }
      if (props.write) {
        await _characteristic!.write(bytes, withoutResponse: false);
        return;
      }
      if (props.writeWithoutResponse) {
        await _characteristic!.write(bytes, withoutResponse: true);
        return;
      }
      throw Exception('Characteristic não suporta escrita.');
    } catch (e) {
      // fallback invertido
      try {
        if (preferWithResponse && (props.writeWithoutResponse)) {
          await _characteristic!.write(bytes, withoutResponse: true);
          return;
        } else if (!preferWithResponse && (props.write)) {
          await _characteristic!.write(bytes, withoutResponse: false);
          return;
        }
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> disconnect({bool release = true}) async {
    try {
      await _charSub?.cancel();
      _charSub = null;
      await _connSub?.cancel();
      _connSub = null;
      if (_device != null) {
        try {
          await _device!.disconnect();
        } catch (e) {
          debugPrint('disconnect erro: $e');
        }
      }
    } finally {
      if (release) _device = null;
      _characteristic = null;
      _deviceController.add(_device);
      _connectionStateController.add(BluetoothConnectionState.disconnected);
      _hasSentStart = false;
      _processingConnected = false;
      _connectCompleter = null;
    }
  }

  BluetoothDevice? get connectedDevice => _device;

  void dispose() {
    _deviceController.close();
    _connectionStateController.close();
    _valueController.close();
  }
}
