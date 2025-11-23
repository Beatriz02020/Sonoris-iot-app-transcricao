import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customSnackBar.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/screens/initial/connection_screen.dart';
import 'package:sonoris/services/auth_service.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  final _birthDateFormatter = _BirthDateInputFormatter();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _authService.signUp(
        name: _nameController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        photo: _selectedImage,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(CustomSnackBar.success('Conta criada com sucesso!'));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConnectionScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(CustomSnackBar.error('Falha ao criar conta: $e'));
    }
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
        title: const Text('Cadastro'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 38, right: 38, bottom: 55),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 1),
                  Column(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          // borda
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.blue500,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : const AssetImage('assets/images/User.png')
                                        as ImageProvider,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: 'Nome',
                        fullWidth: true,
                        controller: _nameController,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Por favor, insira um nome.'
                                    : null,
                      ),
                      CustomTextField(
                        controller: _birthDateController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _birthDateFormatter,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira uma data de nascimento.';
                          }
                          if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                            return 'Formato inválido. Use dd/mm/aaaa.';
                          }

                          // Validação de data real
                          final parts = value.split('/');
                          final dia = int.tryParse(parts[0]);
                          final mes = int.tryParse(parts[1]);
                          final ano = int.tryParse(parts[2]);
                          if (dia == null || mes == null || ano == null) {
                            return 'Data inválida.';
                          }
                          if (mes < 1 || mes > 12) {
                            return 'Mês inválido.';
                          }
                          // Dias máximos por mês
                          final diasPorMes = <int>[
                            31, // Janeiro
                            (ano % 4 == 0 && (ano % 100 != 0 || ano % 400 == 0))
                                ? 29
                                : 28, // Fevereiro
                            31, // Março
                            30, // Abril
                            31, // Maio
                            30, // Junho
                            31, // Julho
                            31, // Agosto
                            30, // Setembro
                            31, // Outubro
                            30, // Novembro
                            31, // Dezembro
                          ];
                          if (dia < 1 || dia > diasPorMes[mes - 1]) {
                            return 'Dia inválido para o mês informado.';
                          }
                          return null;
                        },
                        hintText: 'Data de Nascimento',
                        fullWidth: true,
                      ),
                      CustomTextField(
                        hintText: 'Email',
                        fullWidth: true,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira um e-mail.';
                          }
                          if (!RegExp(
                            r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Por favor, insira um e-mail válido.';
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        hintText: 'Senha',
                        fullWidth: true,
                        keyboardType: TextInputType.visiblePassword,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Por favor, insira uma senha.'
                                    : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.blue500,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  CustomButton(
                    text: 'Cadastrar-se',
                    fullWidth: true,
                    onPressed: _signUp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BirthDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length && i < 8; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
