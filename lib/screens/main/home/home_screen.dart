import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sonoris/components/bottomNavigationBar.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/quickActionsButton.dart';
import 'package:sonoris/screens/main/home/answer_screen.dart';
import 'package:sonoris/screens/main/home/captions_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../services/bluetooth_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BluetoothManager _manager =
      BluetoothManager(); // Certifique-se de inicializar o BluetoothManager
  BluetoothConnectionState _connState = BluetoothConnectionState.disconnected;

  String _userName = ""; // Nome do usuário
  String? _photoUrl; // Foto do usuário
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Assine o estado de conexão para atualizar a UI
    _manager.connectionStateStream.listen((state) {
      setState(() {
        _connState = state;
      });
    });
  }

  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // ouça as mudanças do usuário (foto e nome) em tempo real
      _userStream = FirebaseFirestore.instance
          .collection("Usuario")
          .doc(user.uid)
          .snapshots();

      _userSub = _userStream!.listen((snapshot) {
        if (!mounted) return;
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final primeiroNome = (data['Nome'] ?? '').toString().split(' ').first;
          final foto = (data['Foto_url'] ?? '')?.toString();
          setState(() {
            _userName = primeiroNome;
            _photoUrl = (foto != null && foto.isNotEmpty) ? foto : null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isThisConnected =
        _manager.connectedDevice != null &&
        _connState == BluetoothConnectionState.connected;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.background,
        systemNavigationBarColor: AppColors.blue500,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      /*appBar: AppBar(
        backgroundColor: AppColors.white100,
        iconTheme: const IconThemeData(
          color: AppColors.blue500,
        ),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
        title: const Text(
            'Titulo da pagina'
        ),
      ),*/
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 25,
            right: 25,
            top: 55,
            bottom: 30,
          ),
          child: Column(
            spacing: 10, // 20 padrão
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // nome e foto do usuário
              Row(
                spacing: 10,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: const AssetImage('assets/images/User.png'),
                    foregroundImage:
                        _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                  ),
                  Text(
                    _userName.isNotEmpty ? _userName : "Carregando...",
                    style: AppTextStyles.h4,
                  ),
                ],
              ),

              // card contendo informações do dispositivo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blue950,
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    isThisConnected
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                // logo e nome do dispositivo
                                Row(
                                  spacing: 8,
                                  children: [
                                    SizedBox(
                                      width: 32,
                                      child: Image.asset(
                                        'assets/images/Logo.png',
                                        fit:
                                            BoxFit
                                                .contain, // mantém o aspecto original
                                      ),
                                    ),
                                    Text(
                                      'Sonoris v1.0',
                                      style: AppTextStyles.bold.copyWith(
                                        color: AppColors.white100,
                                      ),
                                    ),
                                  ],
                                ),

                                // bateria do dispositivo
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bateria',
                                      style: AppTextStyles.h4.copyWith(
                                        color: AppColors.blue200,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      '100%',
                                      style: AppTextStyles.h3.copyWith(
                                        color: AppColors.white100,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // TODO: Pegar dados do dispositivo
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                // quantidade de conversas
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Conversas',
                                      style: AppTextStyles.bold.copyWith(
                                        color: AppColors.blue200,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      '185',
                                      style: AppTextStyles.h4.copyWith(
                                        color: AppColors.white100,
                                      ),
                                    ),
                                  ],
                                ),

                                // tempo ativo no app
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tempo Ativo',
                                      style: AppTextStyles.bold.copyWith(
                                        color: AppColors.blue200,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      '1230h',
                                      style: AppTextStyles.h4.copyWith(
                                        color: AppColors.white100,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
                        : Text(
                          'Nenhum dispositivo conectado',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white100,
                          ),
                        ),
              ),

              // ações rápidas
              Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ações rápidas', style: AppTextStyles.body),

                  Row(
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // navegação utilizando container
                      QuickActionsButton(
                        icon: 'RespostasRapidas',
                        text: 'Respostas Rápidas',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnswerScreen(),
                            ),
                          );
                        },
                      ),
                      QuickActionsButton(
                        icon: 'CustomizarLegendas',
                        text: 'Customizar Legendas',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CaptionsScreen(),
                            ),
                          );
                        },
                      ),
                      QuickActionsButton(
                        icon: 'ConfigurarDispositivo',
                        text: 'Configurar Dispositivo',
                        onPressed: () {
                          BottomNav.of(context)?.switchTab(2);
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // conversas não salvas
              Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Conversas não salvas', style: AppTextStyles.body),

                  // card com as conversas
                  // TODO: Pegar informações do Firebase
                  // TODO fazer as conversas serem clicaveis
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white100,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gray900.withAlpha(18),
                          blurRadius: 18.5,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 10,
                      children: [
                        // conversa 1
                        Container(
                          // borda
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white100,
                            border: Border.all(
                              color: AppColors.gray300,
                              width: 1.5, // stroke width
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Conversa_04_07_25_8h',
                                style: AppTextStyles.bold.copyWith(
                                  color: AppColors.gray900,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '04/07/2025',
                                    style: AppTextStyles.medium,
                                  ),
                                  Text(
                                    '08:30 - 11:30',
                                    style: AppTextStyles.medium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // conversa 2
                        Container(
                          // borda
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white100,
                            border: Border.all(
                              color: AppColors.gray300,
                              width: 1.5, // stroke width
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Conversa_04_07_25_8h',
                                style: AppTextStyles.bold.copyWith(
                                  color: AppColors.gray900,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '04/07/2025',
                                    style: AppTextStyles.medium,
                                  ),
                                  Text(
                                    '08:30 - 11:30',
                                    style: AppTextStyles.medium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // button de veja mais
                        // TODO colocar icone (fazer uma variant dele)
                        CustomButton(
                          text: 'Ver todas',
                          outlined: true,
                          fullWidth: false,
                          onPressed: () {
                            Navigator.of(context).pushNamed('/unsavedchats');
                          },
                          // Icon(Icons.circle_outlined, color: AppColors.blue500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
