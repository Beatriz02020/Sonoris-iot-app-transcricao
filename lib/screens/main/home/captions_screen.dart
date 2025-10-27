import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/colorSelector.dart';
import 'package:sonoris/components/customSelect.dart';
import 'package:sonoris/components/customSlider.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class CaptionsScreen extends StatefulWidget {
  const CaptionsScreen({super.key});

  @override
  State<CaptionsScreen> createState() => _CaptionsScreenState();
}

class _CaptionsScreenState extends State<CaptionsScreen> {
  // Colors
  Color _textColorValue = AppColors.blue600;
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
    _loadSettings();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Firestore doc: Usuario/{uid}/preferencias/config (nova coleção)
  DocumentReference<Map<String, dynamic>>? get _configDoc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('Usuario')
        .doc(uid)
        .collection('preferencias')
        .doc('config');
  }

  // Legado: Usuario/{uid}/captions/config (somente leitura para fallback)
  DocumentReference<Map<String, dynamic>>? get _legacyConfigDoc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('Usuario')
        .doc(uid)
        .collection('captions')
        .doc('config');
  }

  Future<void> _loadSettings() async {
    try {
      // Primeiro tenta na nova coleção 'preferencias'
      DocumentSnapshot<Map<String, dynamic>>? snap = await _configDoc?.get();
      Map<String, dynamic>? data = snap?.data();

      // Fallback: se vazio, tenta coleção antiga 'captions'
      if (data == null || data.isEmpty) {
        final legacySnap = await _legacyConfigDoc?.get();
        if (legacySnap != null && legacySnap.exists) {
          data = legacySnap.data();
        }
      }

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
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _saveSettings);
  }

  Future<void> _saveSettings() async {
    final doc = _configDoc;
    if (doc == null) return;
    try {
      await doc.set({
        'textColor': _toHex(_textColorValue),
        'bgColor': _toHex(_bgColorValue),
        'fontFamily': _fontFamily,
        'fontSize': _fontSizeValue,
        'fontWeight': _fontWeightValue,
        'lineHeight': _verticalValue,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // ignore save errors silently
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
                  child: Text(
                    'Este é um texto de exemplo.\n'
                    'As legendas ficarão assim na tela do seu dispositivo.'
                    '\n\nCustomize do melhor jeito para você',
                    style: AppTextStyles.body.copyWith(
                      fontSize: _fontSizeValue * 0.65,
                      fontFamily: '${_fontFamily}Variavel',
                      fontVariations: <FontVariation>[
                        FontVariation('wght', _fontWeightValue),
                      ],
                      color: _textColorValue,
                      height: _verticalValue,
                    ),
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
                                      setState(() => _textColorValue = color);
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
                                      setState(() => _bgColorValue = color);
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
                            setState(() => _fontWeightValue = value);
                            _scheduleSave();
                          },
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
