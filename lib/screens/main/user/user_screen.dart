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

        final nomeCompleto = (data['Nome'] ?? '').toString();
        final primeiroNome = nomeCompleto.split(' ').first;
        final email = (data['Email'] ?? '').toString();
        // final foto = (data['Foto_url'] ?? '').toString();

        // Caso a data de nascimento seja String ou Timestamp
        String dataNascStr = "";
        final rawDataNasc = data['DataNasc'];
        if (rawDataNasc != null) {
          if (rawDataNasc is Timestamp) { // caso seja timestamp
            final dt = rawDataNasc.toDate();
            dataNascStr = "${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}";
          } else { // caso seja string
            dataNascStr = rawDataNasc.toString();
          }
        }

        setState(() {
          _userName = primeiroNome;

          _nameController.text = nomeCompleto;
          _birthDateController.text = dataNascStr;
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
                            controller: _nameController,
                            hintText: 'Nicole Rodrigues',
                            fullWidth: true,
                          ),
                        ],
                      ),

                      // DataNasc
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
                            hintText: '09/11/2006',
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
                            controller: _emailController,
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
