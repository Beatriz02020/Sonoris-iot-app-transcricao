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
  
  // Callback chamado após START ser enviado com sucesso
  Function()? onConnectionEstablished;

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
      debugPrint('[BT_MANAGER] 📞 Chamando device.connect() com timeout de 15s...');
      
      // conecta sem autoConnect
      // NOTA: O RPi está desconectando quando recebe requestMtu automático
      await device.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 15),
      );
      
      debugPrint('[BT_MANAGER] ✅ device.connect() retornou com sucesso!');
      
      // Aguarda conexão estabilizar ANTES de qualquer operação GATT
      debugPrint('[BT_MANAGER] ⏳ Aguardando 800ms pós-conexão (evitar requestMtu prematuro)...');
      await Future.delayed(const Duration(milliseconds: 800));
      debugPrint('[BT_MANAGER] ✅ Estabilização completa');
    } catch (e) {
      // se já estava conectado, device.connect pode lançar; permitimos continuar
      debugPrint('[BT_MANAGER] ⚠️ device.connect erro/aviso: $e');
    }

    // cancelar subscrição anterior se houver e criar nova
    await _connSub?.cancel();
    _connSub = device.connectionState.listen((state) async {
      debugPrint('[BT_MANAGER] 🔄 Estado de conexão mudou: $state');
      _connectionStateController.add(state);

      if (state == BluetoothConnectionState.connected) {
        debugPrint('[BT_MANAGER] ✅ CONECTADO! Iniciando _handleConnected...');
        // quando receber connected, dispara handler (debounced)
        _handleConnected(device, autoReconnect: autoReconnect);
      } else if (state == BluetoothConnectionState.disconnected) {
        debugPrint('[BT_MANAGER] ❌ DESCONECTADO! _hasSentStart=$_hasSentStart, _processingConnected=$_processingConnected');
        // reset flags para próxima conexão
        _hasSentStart = false;
        _processingConnected = false;
        // cancelar stream da char (se houver)
        await _charSub?.cancel();
        _charSub = null;

        // se autoReconnect habilitado, tenta reconectar com backoff
        if (autoReconnect) {
          debugPrint('[BT_MANAGER] 🔁 Auto-reconexão ativada, aguardando 2s...');
          // backoff simples (poderia ser exponencial)
          await Future.delayed(const Duration(seconds: 2));
          if (_device != null) {
            try {
              debugPrint('[BT_MANAGER] 🔁 Tentando reconectar...');
              // tenta reconectar (chamada recursiva controlada)
              await connect(_device!, autoReconnect: autoReconnect);
            } catch (e) {
              debugPrint('[BT_MANAGER] ❌ Reconnect falhou: $e');
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
    debugPrint('[_handleConnected] 🚀 INICIANDO handler. Device: ${device.remoteId}');
    
    if (_processingConnected) {
      debugPrint('[_handleConnected] ⚠️ Já processando connected — ignorando evento duplicado.');
      return;
    }
    _processingConnected = true;
    debugPrint('[_handleConnected] 🔒 Flag _processingConnected = true');

    try {
      // CRITICAL: Aguarda MUITO MAIS tempo - o requestMtu pode estar atrasando tudo
      // O requestMtu deu timeout de 15s, então aguardamos ele terminar completamente
      debugPrint('[_handleConnected] ⏳ Aguardando 3s para requestMtu/conexão estabilizar completamente...');
      await Future.delayed(const Duration(milliseconds: 3000));
      
      // Verifica se ainda está conectado antes de descobrir serviços
      var currentState = await device.connectionState.first;
      debugPrint('[_handleConnected] 🔍 Estado atual da conexão: $currentState');
      if (currentState != BluetoothConnectionState.connected) {
        throw Exception('Dispositivo não está mais conectado (estado: $currentState)');
      }
      
      // discover services (retry até 5 vezes com delay crescente)
      List<BluetoothService> services = [];
      for (int attempt = 1; attempt <= 5; attempt++) {
        debugPrint('[_handleConnected] 🔍 discoverServices tentativa $attempt/5');
        try {
          services = await device.discoverServices();
          debugPrint('[_handleConnected] 📡 Retornou ${services.length} serviços');
          
          // Log DETALHADO dos UUIDs encontrados
          if (services.isNotEmpty) {
            debugPrint('[_handleConnected] ✅ Serviços descobertos:');
            for (var s in services) {
              debugPrint('[_handleConnected]    └─ ${s.uuid}');
              for (var c in s.characteristics) {
                debugPrint('[_handleConnected]       └─ Char: ${c.uuid}');
              }
            }
          } else {
            debugPrint('[_handleConnected] ❌ ZERO serviços retornados (GATT vazio) - pode ser timing issue');
          }
          
          if (services.isNotEmpty) break;
        } catch (e) {
          debugPrint('[_handleConnected] ⚠️ Exceção no discoverServices: $e');
        }
        
        if (attempt < 5) {
          final delayMs = 1500 + (attempt * 500); // 2s, 2.5s, 3s, 3.5s
          debugPrint('[_handleConnected] ⏱️ Aguardando ${delayMs}ms antes de próxima tentativa...');
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      }
      
      if (services.isEmpty) {
        throw Exception(
          '❌ Nenhum serviço GATT encontrado após 5 tentativas. RPi pode estar offline ou serviços não anunciados.'
        );
      }
      
      final service = services.firstWhere(
        (s) => s.uuid.toString().toLowerCase() == SERVICE_UUID.toLowerCase(),
        orElse: () => throw Exception(
          'Serviço $SERVICE_UUID não encontrado.\n'
          'Serviços disponíveis: ${services.map((s) => s.uuid).join(", ")}'
        ),
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
        
        // Chama callback após conexão estabelecida com sucesso
        if (onConnectionEstablished != null) {
          debugPrint('[BT_MANAGER] 🔔 Chamando onConnectionEstablished callback...');
          onConnectionEstablished!();
        }
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
