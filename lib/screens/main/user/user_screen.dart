import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../models/usuario.dart';


class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();

  String _userName = ""; // nome do usuário
  // final _birthDateFormatter = _BirthDateInputFormatter();

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

      final snapshot = await FirebaseFirestore.instance
          .collection("Usuario")
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        print("Dados recebidos: $data");

        final nome = (data['Nome'] ?? '').toString();
        // final email = (data['Email'] ?? '').toString();
        // final foto = (data['Foto_url'] ?? '').toString();

        setState(() {
          _userName = nome;

          //_nameController.text = _userName;
          //_birthDateController.text = data["birthDate"] ?? "";
          //_emailController.text = usuario.email ?? "";
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
                    backgroundImage: AssetImage('assets/images/Avatar.jpg'),
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
                      // titulo
                      Text(
                        _userName.isNotEmpty ? _userName : "Carregando...",
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.blue950,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // nome
                          Text(
                            'Nome',
                            style: AppTextStyles.bold.copyWith(
                              color: AppColors.gray900,
                            ),
                          ),
                          CustomTextField(
                            hintText: 'Nicole Rodrigues',
                            fullWidth: true,
                          ),
                        ],
                      ),

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
                            hintText: '09/11/2006',
                            fullWidth: true,
                          ),
                        ],
                      ),

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
                            hintText: 'Nicole@Rodrigues.com',
                            fullWidth: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CustomButton(
                        text: 'Salvar',
                        fullWidth: true,
                        onPressed: () {},
                      ),

                      CustomButton(
                        color: AppColors.rose500,
                        text: 'Sair',
                        fullWidth: true,
                        onPressed: () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushReplacementNamed('/initial');
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
      )
    );
  }
}
