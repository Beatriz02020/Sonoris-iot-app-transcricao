// lib/services/bluetooth_manager.dart
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _deviceNameController = StreamController<String>.broadcast();

  Stream<BluetoothDevice?> get deviceStream => _deviceController.stream;
  Stream<BluetoothConnectionState> get connectionStateStream =>
      _connectionStateController.stream;
  Stream<String> get valueStream => _valueController.stream;
  Stream<String> get deviceNameStream => _deviceNameController.stream;

  // internals
  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  BluetoothCharacteristic? _deviceInfoCharacteristic;
  BluetoothCharacteristic? _deviceNameCharacteristic;
  BluetoothCharacteristic? _conversationsCharacteristic;
  BluetoothCharacteristic? _transcriptionStreamCharacteristic;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<int>>? _charSub;
  StreamSubscription<List<int>>? _conversationsSub;
  StreamSubscription<List<int>>? _transcriptionStreamSub;

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

  // Callback chamado quando dispositivo desconecta
  Function()? onDisconnected;

  // Callback chamado quando conversas são recebidas via BLE
  Function(List<Map<String, dynamic>>)? onConversationsReceived;

  // UUIDs do peripheral (públicos para serem usados em filtros de scan)
  static const String SERVICE_UUID = "12345678-1234-5678-1234-56789abcdef0";
  static const String CHAR_UUID = "12345678-1234-5678-1234-56789abcdef1";
  static const String DEVICE_INFO_UUID = "12345678-1234-5678-1234-56789abcdef2";
  static const String DEVICE_NAME_UUID = "12345678-1234-5678-1234-56789abcdef3";
  static const String CONVERSATIONS_UUID =
      "12345678-1234-5678-1234-56789abcdef4";
  static const String TRANSCRIPTION_STREAM_UUID =
      "12345678-1234-5678-1234-56789abcdef5";

  /// Conecta ao device. Retorna quando a sequência de discover + (notify se houver) + write("START")
  /// for concluída com sucesso (ou lança erro).
  Future<void> connect(BluetoothDevice device) async {
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
      // conecta sem autoConnect
      // NOTA: O RPi está desconectando quando recebe requestMtu automático
      await device.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 15),
      );

      // Aguarda conexão estabilizar ANTES de qualquer operação GATT
      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      // se já estava conectado, device.connect pode lançar; permitimos continuar
      debugPrint('[BT_MANAGER] device.connect erro/aviso: $e');
    }

    // cancelar subscrição anterior se houver e criar nova
    await _connSub?.cancel();
    _connSub = device.connectionState.listen((state) async {
      _connectionStateController.add(state);

      if (state == BluetoothConnectionState.connected) {
        // quando receber connected, dispara handler (debounced)
        _handleConnected(device);
      } else if (state == BluetoothConnectionState.disconnected) {
        // Chama callback de desconexão se existir
        if (onDisconnected != null) {
          onDisconnected!();
        }

        // reset flags para próxima conexão
        _hasSentStart = false;
        _processingConnected = false;
        // cancelar stream da char (se houver)
        await _charSub?.cancel();
        _charSub = null;
        await _conversationsSub?.cancel();
        _conversationsSub = null;
        await _transcriptionStreamSub?.cancel();
        _transcriptionStreamSub = null;
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
  Future<void> _handleConnected(BluetoothDevice device) async {
    if (_processingConnected) {
      return;
    }
    _processingConnected = true;

    try {
      // CRITICAL: Aguarda MUITO MAIS tempo - o requestMtu pode estar atrasando tudo
      // O requestMtu deu timeout de 15s, então aguardamos ele terminar completamente
      await Future.delayed(const Duration(milliseconds: 3000));

      // Verifica se ainda está conectado antes de descobrir serviços
      var currentState = await device.connectionState.first;
      if (currentState != BluetoothConnectionState.connected) {
        throw Exception(
          'Dispositivo não está mais conectado (estado: $currentState)',
        );
      }

      // discover services (retry até 5 vezes com delay crescente)
      List<BluetoothService> services = [];
      for (int attempt = 1; attempt <= 5; attempt++) {
        try {
          services = await device.discoverServices();

          if (services.isNotEmpty) break;
        } catch (e) {
          debugPrint('[_handleConnected] Exceção no discoverServices: $e');
        }

        if (attempt < 5) {
          final delayMs = 1500 + (attempt * 500); // 2s, 2.5s, 3s, 3.5s
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      }

      if (services.isEmpty) {
        throw Exception(
          'Nenhum serviço GATT encontrado após 5 tentativas. RPi pode estar offline ou serviços não anunciados.',
        );
      }

      final service = services.firstWhere(
        (s) => s.uuid.toString().toLowerCase() == SERVICE_UUID.toLowerCase(),
        orElse:
            () =>
                throw Exception(
                  'Serviço $SERVICE_UUID não encontrado.\n'
                  'Serviços disponíveis: ${services.map((s) => s.uuid).join(", ")}',
                ),
      );

      final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString().toLowerCase() == CHAR_UUID.toLowerCase(),
        orElse:
            () => throw Exception('Characteristic $CHAR_UUID não encontrado'),
      );

      _characteristic = characteristic;

      // Procura pela characteristic de device info
      try {
        final deviceInfoChar = service.characteristics.firstWhere(
          (c) =>
              c.uuid.toString().toLowerCase() == DEVICE_INFO_UUID.toLowerCase(),
        );
        _deviceInfoCharacteristic = deviceInfoChar;
      } catch (e) {
        debugPrint(
          '[BT_MANAGER] Device info characteristic não encontrada: $e',
        );
      }

      // Procura pela characteristic de device name
      try {
        final deviceNameChar = service.characteristics.firstWhere(
          (c) =>
              c.uuid.toString().toLowerCase() == DEVICE_NAME_UUID.toLowerCase(),
        );
        _deviceNameCharacteristic = deviceNameChar;
      } catch (e) {
        debugPrint(
          '[BT_MANAGER] Device name characteristic não encontrada: $e',
        );
      }

      // Procura pela characteristic de conversas
      try {
        final conversationsChar = service.characteristics.firstWhere(
          (c) =>
              c.uuid.toString().toLowerCase() ==
              CONVERSATIONS_UUID.toLowerCase(),
        );
        _conversationsCharacteristic = conversationsChar;
      } catch (e) {
        debugPrint(
          '[BT_MANAGER] Conversations characteristic não encontrada: $e',
        );
      }

      // Procura pela characteristic de transcription stream
      try {
        final transcriptionStreamChar = service.characteristics.firstWhere(
          (c) =>
              c.uuid.toString().toLowerCase() ==
              TRANSCRIPTION_STREAM_UUID.toLowerCase(),
        );
        _transcriptionStreamCharacteristic = transcriptionStreamChar;
      } catch (e) {
        debugPrint(
          '[BT_MANAGER] Transcription stream characteristic não encontrada: $e',
        );
      }

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

      // Habilita notify para conversations characteristic se disponível
      if (_conversationsCharacteristic != null) {
        try {
          final convProps = _conversationsCharacteristic!.properties;
          if (convProps.notify || convProps.indicate) {
            await _conversationsCharacteristic!.setNotifyValue(true);
            await _conversationsSub?.cancel();
            _conversationsSub = _conversationsCharacteristic!.value.listen((
              bytes,
            ) {
              _handleConversationsData(bytes);
            });
          }
        } catch (e) {
          debugPrint(
            '[BT_MANAGER] Erro ao habilitar notify para conversations: $e',
          );
        }
      }

      // DEBOUNCE & prevenção de envios duplicados:
      // evita reenviar START num intervalo curto
      final now = DateTime.now();
      if (_hasSentStart && _lastStartSentAt != null) {
        final diff = now.difference(_lastStartSentAt!);
        if (diff.inMilliseconds < 800) {
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

        // Chama callback após conexão estabelecida com sucesso
        if (onConnectionEstablished != null) {
          onConnectionEstablished!();
        }

        // Envia configurações de legenda automaticamente ao conectar
        await _sendCaptionSettingsOnConnect();
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
      debugPrint('[BT_MANAGER] _handleConnected erro: $e');
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
            await _characteristic!.write(bytes, withoutResponse: false);
            return; // sucesso
          } else if (canWriteWithoutResponse) {
            await _characteristic!.write(bytes, withoutResponse: true);
            return;
          }
        } else {
          // tenta withoutResponse primeiro
          if (canWriteWithoutResponse) {
            await _characteristic!.write(bytes, withoutResponse: true);
            return;
          } else if (canWriteWithResponse) {
            await _characteristic!.write(bytes, withoutResponse: false);
            return;
          }
        }
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        debugPrint('[BT_MANAGER] write attempt $attempt falhou: $e');
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
      await _conversationsSub?.cancel();
      _conversationsSub = null;
      await _transcriptionStreamSub?.cancel();
      _transcriptionStreamSub = null;
      await _connSub?.cancel();
      _connSub = null;
      if (_device != null) {
        try {
          await _device!.disconnect();
        } catch (e) {
          debugPrint('[BT_MANAGER] disconnect erro: $e');
        }
      }
    } finally {
      if (release) _device = null;
      _characteristic = null;
      _conversationsCharacteristic = null;
      _transcriptionStreamCharacteristic = null;
      _deviceController.add(_device);
      _connectionStateController.add(BluetoothConnectionState.disconnected);
      _hasSentStart = false;
      _processingConnected = false;
      _connectCompleter = null;
    }
  }

  BluetoothDevice? get connectedDevice => _device;

  /// Carrega configurações de legenda do Firebase e envia via Bluetooth
  Future<void> _sendCaptionSettingsOnConnect() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return;
      }

      final configDoc = FirebaseFirestore.instance
          .collection('Usuario')
          .doc(uid)
          .collection('Legenda')
          .doc('config');

      final snap = await configDoc.get();
      final data = snap.data();

      if (data == null || data.isEmpty) {
        return;
      }

      // Remove updatedAt que não é necessário para o dispositivo
      final bleSettings = Map<String, dynamic>.from(data);
      bleSettings.remove('updatedAt');

      // Converte para JSON
      final jsonStr = jsonEncode(bleSettings);

      // Envia com prefixo SETTINGS:
      final message = 'SETTINGS:$jsonStr';

      await writeString(message);
    } catch (e) {
      debugPrint('[BT_MANAGER] Erro ao enviar caption settings: $e');
      // Não propaga o erro - envio é best-effort
    }
  }

  /// Requisita lista de conversas do dispositivo
  Future<void> requestConversations() async {
    try {
      if (_characteristic == null) {
        throw Exception('Characteristic não configurada');
      }

      // Envia comando LIST para requisitar conversas
      await writeString('LIST');

      // Aguarda mais tempo para garantir que resposta esteja pronta
      await Future.delayed(const Duration(milliseconds: 2000));

      if (_conversationsCharacteristic != null) {
        final bytes = await _conversationsCharacteristic!.read();

        // Processa manualmente sem callback automático
        if (bytes.isNotEmpty) {
          final jsonString = utf8.decode(bytes);

          final dynamic decodedJson = jsonDecode(jsonString);
          List<Map<String, dynamic>> conversations = [];

          if (decodedJson is List) {
            conversations = decodedJson.cast<Map<String, dynamic>>();
          } else if (decodedJson is Map) {
            conversations = [decodedJson.cast<String, dynamic>()];
          }

          // Chama callback apenas uma vez
          if (onConversationsReceived != null) {
            onConversationsReceived!(conversations);
          }
        }
      }
    } catch (e) {
      debugPrint('[BT_MANAGER] Erro ao requisitar conversas: $e');
    }
  }

  /// Processa dados de conversas recebidos via BLE
  void _handleConversationsData(List<int> bytes) {
    // Apenas um placeholder
    // Não fazemos nada aqui para evitar callbacks automáticos
    // As leituras são feitas manualmente pelas funções request*
  }

  /// Requisita metadados de uma conversa específica por ID
  /// Retorna informações sobre chunks necessários para download
  Future<Map<String, dynamic>?> requestConversationById(
    String conversationId,
  ) async {
    try {
      if (_characteristic == null) {
        throw Exception('Characteristic não configurada');
      }

      // Envia comando GET:id para obter metadados
      await writeString('GET:$conversationId');

      // Aguarda resposta - aumentado para garantir processamento
      await Future.delayed(const Duration(milliseconds: 2500));

      if (_conversationsCharacteristic != null) {
        final bytes = await _conversationsCharacteristic!.read();
        if (bytes.isNotEmpty) {
          final jsonString = utf8.decode(bytes);

          // Verifica se o JSON está truncado
          final trimmed = jsonString.trim();
          if (!trimmed.endsWith(']') && !trimmed.endsWith('}')) {
            debugPrint(
              '[BT_MANAGER] JSON truncado detectado para conversa $conversationId',
            );
            return null;
          }

          final decoded = jsonDecode(jsonString);

          // Verifica se é uma lista (erro) ou mapa (correto)
          if (decoded is List) {
            debugPrint('[BT_MANAGER] Resposta é uma lista, esperava objeto');
            return null;
          }

          return decoded as Map<String, dynamic>;
        }
      }

      return null;
    } catch (e) {
      debugPrint(
        '[BT_MANAGER] Erro ao requisitar metadados $conversationId: $e',
      );
      return null;
    }
  }

  /// Requisita um chunk específico de uma conversa
  Future<Map<String, dynamic>?> requestConversationChunk(
    String conversationId,
    int chunkIndex,
  ) async {
    try {
      if (_characteristic == null) {
        throw Exception('Characteristic não configurada');
      }

      // Envia comando CHUNK:id:index
      final command = 'CHUNK:$conversationId:$chunkIndex';
      await writeString(command);

      // Aguarda resposta - aumentado para dar tempo do device processar
      await Future.delayed(const Duration(milliseconds: 2500));

      if (_conversationsCharacteristic != null) {
        final bytes = await _conversationsCharacteristic!.read();
        if (bytes.isNotEmpty) {
          final jsonString = utf8.decode(bytes);

          // Verifica se o JSON está truncado
          final trimmed = jsonString.trim();
          if (!trimmed.endsWith(']') && !trimmed.endsWith('}')) {
            debugPrint('[BT_MANAGER] Chunk $chunkIndex truncado');
            return null;
          }

          final decoded = jsonDecode(jsonString);

          if (decoded is! Map<String, dynamic>) {
            debugPrint(
              '[BT_MANAGER] Formato de chunk inválido - recebido ${decoded.runtimeType}',
            );
            return null;
          }

          return decoded;
        } else {
          debugPrint('[BT_MANAGER] Resposta vazia para chunk $chunkIndex');
        }
      }

      return null;
    } catch (e) {
      debugPrint('[BT_MANAGER] Erro ao requisitar chunk $chunkIndex: $e');
      return null;
    }
  }

  /// Deleta uma conversa do dispositivo
  Future<bool> deleteConversationFromDevice(String conversationId) async {
    try {
      if (_characteristic == null) {
        throw Exception('Characteristic não configurada');
      }

      // Envia comando DEL:id
      await writeString('DEL:$conversationId');

      return true;
    } catch (e) {
      debugPrint('[BT_MANAGER] Erro ao deletar conversa: $e');
      return false;
    }
  }

  /// Requisita informações do dispositivo (nome, tempo ativo, conversas)
  Future<Map<String, dynamic>?> requestDeviceInfo() async {
    try {
      if (_device == null) {
        debugPrint('[BT_MANAGER] Nenhum dispositivo conectado');
        return null;
      }

      if (_deviceInfoCharacteristic == null) {
        debugPrint('[BT_MANAGER] Device info characteristic não disponível');
        return null;
      }

      // Lê a characteristic de device info
      final bytes = await _deviceInfoCharacteristic!.read();

      if (bytes.isEmpty) {
        debugPrint('[BT_MANAGER] Resposta vazia do dispositivo');
        return null;
      }

      final jsonString = utf8.decode(bytes);
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

      return decoded;
    } catch (e, stackTrace) {
      debugPrint('[BT_MANAGER] Erro ao requisitar device info: $e');
      debugPrint('[BT_MANAGER] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Atualiza o nome do dispositivo via BLE
  Future<bool> updateDeviceName(String newName) async {
    try {
      if (_deviceNameCharacteristic == null) {
        debugPrint('[BT_MANAGER] Device name characteristic não disponível');
        return false;
      }

      // Escreve o novo nome na characteristic
      final bytes = utf8.encode(newName);
      await _deviceNameCharacteristic!.write(bytes, withoutResponse: false);

      // Notifica todas as telas que o nome foi atualizado
      _deviceNameController.add(newName);

      return true;
    } catch (e) {
      debugPrint('[BT_MANAGER] Erro ao atualizar nome do dispositivo: $e');
      return false;
    }
  }

  void dispose() {
    _deviceController.close();
    _connectionStateController.close();
    _valueController.close();
    _deviceNameController.close();
  }
}
