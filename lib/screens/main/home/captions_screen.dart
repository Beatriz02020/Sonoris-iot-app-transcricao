import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/colorSelector.dart';
import 'package:sonoris/components/customSelect.dart';
import 'package:sonoris/components/customSlider.dart';
import 'package:sonoris/services/bluetooth_manager.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class CaptionsScreen extends StatefulWidget {
  const CaptionsScreen({super.key});

  @override
  State<CaptionsScreen> createState() => _CaptionsScreenState();
}

class _CaptionsScreenState extends State<CaptionsScreen> {
  // Colors
  Color _textColorValue = AppColors.gray900;
  Color _bgColorValue = AppColors.white100;

  // Sliders
  double _fontSizeValue = 36;
  double _fontWeightValue = 400;
  double _verticalValue = 1.2; // line height

  // Dropdowns
  String _fontFamily = 'Inter';

  // Persistence debounce
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadSettings().then((_) {
      // Após carregar settings, verifica se já há conexão BLE e envia
      _checkAndSendSettingsIfConnected();
    });

    // Registra callback para enviar settings ao conectar
    BluetoothManager().onConnectionEstablished =
        _sendCurrentSettingsToBluetooth;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // Remove callback ao descartar a tela
    BluetoothManager().onConnectionEstablished = null;
    super.dispose();
  }

  // Firestore doc: Usuario/{uid}/Legenda/config
  DocumentReference<Map<String, dynamic>>? get _configDoc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('Usuario')
        .doc(uid)
        .collection('Legenda')
        .doc('config');
  }

  Future<void> _loadSettings() async {
    try {
      DocumentSnapshot<Map<String, dynamic>>? snap = await _configDoc?.get();
      Map<String, dynamic>? data = snap?.data();

      if (data != null && data.isNotEmpty) {
        final d = data;
        setState(() {
          _textColorValue = _colorFromHex(d['textColor']) ?? _textColorValue;
          _bgColorValue = _colorFromHex(d['bgColor']) ?? _bgColorValue;
          _fontFamily = (d['fontFamily'] ?? _fontFamily).toString();
          _fontSizeValue = _toDouble(d['fontSize'], _fontSizeValue);
          _fontWeightValue = _toDouble(d['fontWeight'], _fontWeightValue);
          _verticalValue = _toDouble(d['lineHeight'], _verticalValue);
        });
      }
    } catch (_) {
      // ignore load errors silently
    }
  }

  void _scheduleSave() {
    debugPrint(
      '[Captions] 🕐 _scheduleSave() chamado - agendando save em 450ms',
    );
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _saveSettings);
  }

  Future<void> _saveSettings() async {
    debugPrint('[Captions] 💾 _saveSettings() INICIADO');
    final doc = _configDoc;
    if (doc == null) {
      debugPrint('[Captions] ❌ _configDoc é NULL - usuário não autenticado?');
      return;
    }
    try {
      final settingsMap = {
        'textColor': _toHex(_textColorValue),
        'bgColor': _toHex(_bgColorValue),
        'fontFamily': _fontFamily,
        'fontSize': _fontSizeValue,
        'fontWeight': _fontWeightValue,
        'lineHeight': _verticalValue,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      debugPrint('[Captions] 💾 Salvando no Firestore: $settingsMap');
      await doc.set(settingsMap, SetOptions(merge: true));
      debugPrint('[Captions] ✅ Firestore salvo com sucesso!');

      // Envia configurações via Bluetooth para o dispositivo Raspberry Pi
      debugPrint('[Captions] 🔵 Chamando _sendSettingsToBluetooth...');
      await _sendSettingsToBluetooth(settingsMap);
      debugPrint('[Captions] ✅ _sendSettingsToBluetooth completou!');
    } catch (e) {
      debugPrint('[Captions] ❌ ERRO em _saveSettings: $e');
    }
  }

  Future<void> _sendSettingsToBluetooth(Map<String, dynamic> settings) async {
    try {
      final manager = BluetoothManager();

      debugPrint('[Captions] 🔍 Verificando conexão BLE...');
      debugPrint(
        '[Captions] 🔍 connectedDevice: ${manager.connectedDevice?.remoteId}',
      );

      // Verifica se há dispositivo conectado
      if (manager.connectedDevice == null) {
        debugPrint(
          '[Captions] ❌ Nenhum dispositivo BLE conectado - pulando envio',
        );
        return;
      }

      // Remove updatedAt que não é necessário para o dispositivo
      final bleSettings = Map<String, dynamic>.from(settings);
      bleSettings.remove('updatedAt');

      // Converte para JSON
      final jsonStr = jsonEncode(bleSettings);

      // Envia com prefixo SETTINGS:
      final message = 'SETTINGS:$jsonStr';

      debugPrint(
        '[Captions] 📤 Enviando settings via BLE (${message.length} chars)',
      );
      debugPrint('[Captions] 📦 Payload: $message');
      await manager.writeString(message);
      debugPrint('[Captions] ✅ Settings enviados com sucesso!');
    } catch (e) {
      debugPrint('[Captions] ❌ Erro ao enviar settings via BLE: $e');
      debugPrint('[Captions] ❌ Stack: ${StackTrace.current}');
      // Não propaga o erro - envio BLE é best-effort
    }
  }

  /// Envia as configurações ATUAIS (em memória) via Bluetooth
  /// Chamado automaticamente quando a conexão BLE é estabelecida
  Future<void> _sendCurrentSettingsToBluetooth() async {
    debugPrint(
      '[Captions] 🚀 onConnectionEstablished - enviando settings atuais...',
    );

    final currentSettings = {
      'textColor': _toHex(_textColorValue),
      'bgColor': _toHex(_bgColorValue),
      'fontFamily': _fontFamily,
      'fontSize': _fontSizeValue,
      'fontWeight': _fontWeightValue,
      'lineHeight': _verticalValue,
    };

    await _sendSettingsToBluetooth(currentSettings);
  }

  /// Verifica se já há conexão BLE ativa e envia settings
  /// Chamado quando a tela é carregada
  Future<void> _checkAndSendSettingsIfConnected() async {
    final manager = BluetoothManager();

    debugPrint('[Captions] 🔍 Verificando se há conexão BLE ativa...');

    if (manager.connectedDevice != null) {
      debugPrint('[Captions] ✅ Dispositivo já conectado! Enviando settings...');
      await _sendCurrentSettingsToBluetooth();
    } else {
      debugPrint('[Captions] ℹ️ Nenhum dispositivo conectado ainda');
    }
  }

  // Helpers
  static String _toHex(Color c) =>
      '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  static Color? _colorFromHex(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    try {
      var hex = s.replaceAll('#', '');
      if (hex.length == 6) hex = 'ff$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return null;
    }
  }

  static double _toDouble(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    final s = v.toString();
    return double.tryParse(s) ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '[Captions] 🏗️ BUILD CHAMADO - Tela CaptionsScreen está sendo renderizada!',
    );
    debugPrint(
      '[Captions] 📊 Estado atual: textColor=${_textColorValue.toString()}, bgColor=${_bgColorValue.toString()}',
    );

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
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 0),
        child: Column(
          spacing: 25,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview (binds to state, no layout change)
            SizedBox(
              height: 160, // mantém altura do container constante
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: _bgColorValue,
                  border: Border.all(color: AppColors.blue700, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Builder(
                    builder: (context) {
                      debugPrint(
                        '[Captions] 🎨 Preview renderizando com: font=$_fontFamily, size=${_fontSizeValue.round()}, weight=${_fontWeightValue.round()}',
                      );

                      // Mapeia o valor numérico para FontWeight
                      FontWeight fontWeight;
                      if (_fontWeightValue <= 150) {
                        fontWeight = FontWeight.w100;
                      } else if (_fontWeightValue <= 250) {
                        fontWeight = FontWeight.w200;
                      } else if (_fontWeightValue <= 350) {
                        fontWeight = FontWeight.w300;
                      } else if (_fontWeightValue <= 450) {
                        fontWeight = FontWeight.w400;
                      } else if (_fontWeightValue <= 550) {
                        fontWeight = FontWeight.w500;
                      } else if (_fontWeightValue <= 650) {
                        fontWeight = FontWeight.w600;
                      } else if (_fontWeightValue <= 750) {
                        fontWeight = FontWeight.w700;
                      } else if (_fontWeightValue <= 850) {
                        fontWeight = FontWeight.w800;
                      } else {
                        fontWeight = FontWeight.w900;
                      }

                      return Text(
                        'Este é um texto de exemplo.\n'
                        'As legendas ficarão assim na tela do seu dispositivo.'
                        '\n\nCustomize do melhor jeito para você',
                        style: AppTextStyles.body.copyWith(
                          fontSize: _fontSizeValue * 0.65,
                          fontFamily: '${_fontFamily}Variavel',
                          fontWeight: fontWeight,
                          fontVariations: <FontVariation>[
                            FontVariation('wght', _fontWeightValue),
                          ],
                          color: _textColorValue,
                          height: _verticalValue,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 20),
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
                                  ColorSelector(
                                    colors: const [
                                      Colors.transparent,
                                      AppColors.gray900,
                                      AppColors.gray700,
                                      AppColors.gray500,
                                      AppColors.white100,
                                      AppColors.blue600,
                                      AppColors.green500,
                                      AppColors.rose600,
                                      AppColors.amber600,
                                      AppColors.indigo600,
                                      AppColors.teal600,
                                    ],
                                    selectedColor: _textColorValue,
                                    enableCustomPicker: true,
                                    onColorSelected: (color) {
                                      debugPrint(
                                        '[Captions] 🎨 COR DE TEXTO MUDOU: ${color.toString()}',
                                      );
                                      setState(() => _textColorValue = color);
                                      debugPrint(
                                        '[Captions] 🎨 setState executado, chamando _scheduleSave...',
                                      );
                                      _scheduleSave();
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
                                  ColorSelector(
                                    colors: const [
                                      Colors.transparent,
                                      AppColors.gray900,
                                      AppColors.gray700,
                                      AppColors.gray500,
                                      AppColors.white100,
                                      AppColors.blue600,
                                      AppColors.green500,
                                      AppColors.rose600,
                                      AppColors.amber600,
                                      AppColors.indigo600,
                                      AppColors.teal600,
                                    ],
                                    selectedColor: _bgColorValue,
                                    enableCustomPicker: true,
                                    onColorSelected: (color) {
                                      debugPrint(
                                        '[Captions] 🎨 COR DE FUNDO MUDOU: ${color.toString()}',
                                      );
                                      setState(() => _bgColorValue = color);
                                      debugPrint(
                                        '[Captions] 🎨 setState executado, chamando _scheduleSave...',
                                      );
                                      _scheduleSave();
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
                          child: CustomSelect(
                            options: const ['Inter', 'Roboto', 'Poppins'],
                            value: _fontFamily,
                            onChanged: (value) {
                              if (value == null) return;
                              debugPrint('[Captions] 🔤 FONTE MUDOU: $value');
                              setState(() => _fontFamily = value);
                              _scheduleSave();
                            },
                            hintText: '',
                          ),
                        ),
                        CustomSlider(
                          label: 'Tamanho da Fonte',
                          value: _fontSizeValue,
                          min: 16,
                          max: 56,
                          onChanged: (value) {
                            debugPrint(
                              '[Captions] 📏 TAMANHO FONTE MUDOU: ${value.round()}pt',
                            );
                            setState(() => _fontSizeValue = value);
                            _scheduleSave();
                          },
                          valueLabel: '${_fontSizeValue.round()}pt',
                        ),
                        CustomSlider(
                          label: 'Grossura da Fonte',
                          value: _fontWeightValue,
                          min: 100,
                          max: 900,
                          step: 100,
                          onChanged: (value) {
                            debugPrint(
                              '[Captions] ⚖️ WEIGHT MUDOU: ${value.round()}',
                            );
                            setState(() => _fontWeightValue = value);
                            _scheduleSave();
                          },
                          valueLabel: '${_fontWeightValue.round()}',
                        ),
                        CustomSlider(
                          label: 'Tamanho da linha',
                          value: _verticalValue,
                          min: 0.8,
                          max: 1.6,
                          step: 0.1,
                          onChanged: (value) {
                            setState(() => _verticalValue = value);
                            _scheduleSave();
                          },
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
