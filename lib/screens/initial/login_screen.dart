import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customSnackBar.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final credential = await _authService.signIn(
        email: email,
        password: password,
      );

      // Busca documento do usuário para confirmar existência de perfil
      // FUTURO: mover este fetch para um provider/global store e carregar
      // demais recursos (ex: preferências, categorias) em paralelo.
      final userDoc =
          await FirebaseFirestore.instance
              .collection('Usuario')
              .doc(credential.user!.uid)
              .get();

      if (!userDoc.exists) {
        throw Exception('Perfil de usuário não encontrado.');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(CustomSnackBar.success('Logado com sucesso!'));

      Navigator.of(context, rootNavigator: true).pushReplacementNamed('/main');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          message = 'Senha incorreta.';
          break;
        case 'invalid-credential':
          message = 'Credenciais inválidas.';
          break;
        case 'too-many-requests':
          message = 'Muitas tentativas. Tente mais tarde.';
          break;
        default:
          message = 'Erro de autenticação: ${e.code}';
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar.error(message));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar.error(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

    return Scaffold(
      backgroundColor: AppColors.white100,
      appBar: AppBar(
        backgroundColor: AppColors.white100, // cor de fundo da AppBar
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.blue500, // cor dos ícones (ex: seta de voltar)
        ),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text('Login'),
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
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.095, // ~38px
                right: MediaQuery.of(context).size.width * 0.095, // ~38px
                top: 0,
                bottom: MediaQuery.of(context).size.height * 0.065, // ~55px
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 1),
                    Column(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width:
                              MediaQuery.of(context).size.width *
                              0.45, // ~175px em tela de 390px
                          child: Image.asset(
                            'assets/images/Logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        CustomTextField(
                          hintText: 'Email',
                          fullWidth: true,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: (value) {
                            // verifica se o usuário digitou e-mail
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira um e-mail.';
                            }

                            // verifica se o usuário digitou e-mail válido
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
                      text: _isLoading ? 'Entrando...' : 'Entrar',
                      fullWidth: true,
                      onPressed: _isLoading ? null : _login,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
