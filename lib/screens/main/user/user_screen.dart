import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();

  String _userName = ""; // nome do usuário
  final _birthDateFormatter = _BirthDateInputFormatter();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Busca dados de usuários logados
  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // print("Usuário logado: ${user.uid}"); // depuração

      final snapshot =
          await FirebaseFirestore.instance
              .collection("Usuario")
              .doc(user.uid)
              .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        // print("Dados recebidos: $data");

        final nomeCompleto = (data['Nome'] ?? '').toString();
        final primeiroNome = nomeCompleto.split(' ').first;
        final dataNasc = (data['DataNasc'] ?? '').toString();
        final email = (data['Email'] ?? '').toString();
        // final foto = (data['Foto_url'] ?? '').toString();

        setState(() {
          _userName = primeiroNome;
          _nameController.text = nomeCompleto;
          _birthDateController.text = dataNasc;
          _emailController.text = email;
        });
      }
    }
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // banner e avatar
                  // TODO: Adicionar banner placeholder
                  Container(
                    color: AppColors.blue200,
                    width: double.infinity,
                    height: 180,
                    child: ClipRRect(
                      child: Image.asset(
                        'assets/images/BannerPerfil.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: MediaQuery.of(context).size.width / 2 - 50,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/User.png'),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                  top: 55,
                  bottom: 30,
                ),
                child: Column(
                  spacing: 38,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 12,
                      children: [
                        // Titulo
                        Text(
                          _userName.isNotEmpty ? _userName : "Carregando...",
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.blue950,
                          ),
                        ),

                        // Nome
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nome',
                              style: AppTextStyles.bold.copyWith(
                                color: AppColors.gray900,
                              ),
                            ),
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
                          ],
                        ),

                        // Data de Nascimento
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data de Nascimento',
                              style: AppTextStyles.bold.copyWith(
                                color: AppColors.gray900,
                              ),
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
                                if (!RegExp(
                                  r'^\d{2}/\d{2}/\d{4}$',
                                ).hasMatch(value)) {
                                  return 'Formato inválido. Use dd/mm/aaaa.';
                                }
                                return null;
                              },
                              hintText: 'Data de Nascimento',
                              fullWidth: true,
                            ),
                          ],
                        ),

                        // Email
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: AppTextStyles.bold.copyWith(
                                color: AppColors.gray900,
                              ),
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
                          ],
                        ),
                      ],
                    ),
                    Column(
                      spacing: 10,
                      children: [
                        CustomButton(
                          text: 'Salvar',
                          fullWidth: true,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                await FirebaseFirestore.instance
                                    .collection('Usuario')
                                    .doc(user.uid)
                                    .update({
                                      'Nome': _nameController.text,
                                      'DataNasc': _birthDateController.text,
                                      'Email': _emailController.text,
                                    });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.blue500,
                                    duration: Duration(seconds: 3),
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    content: Text(
                                      'Informações salvas com sucesso!',
                                      style: TextStyle(
                                        color: AppColors.white100,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        CustomButton(
                          color: AppColors.rose500,
                          text: 'Sair',
                          fullWidth: true,
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut(); // Desconecta o usuário
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushReplacementNamed('/initial'); // Redireciona para a tela inicial
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
