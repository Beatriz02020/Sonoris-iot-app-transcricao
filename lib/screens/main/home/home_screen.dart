import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sonoris/components/bottomNavigationBar.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customSnackBar.dart';
import 'package:sonoris/components/quickActionsButton.dart';
import 'package:sonoris/screens/main/home/answer_screen.dart';
import 'package:sonoris/screens/main/home/captions_screen.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../models/conversa.dart';
import '../../../services/bluetooth_manager.dart';
import '../../../services/conversa_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BluetoothManager _manager =
      BluetoothManager(); // Certifique-se de inicializar o BluetoothManager
  BluetoothConnectionState _connState = BluetoothConnectionState.disconnected;
  final ConversaService _conversaService = ConversaService();

  String _userName = ""; // Nome do usuário
  String? _photoUrl; // Foto do usuário
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  StreamSubscription<BluetoothConnectionState>? _connStateSub;
  StreamSubscription<String>? _deviceNameSub;

  // Informações do dispositivo
  String _deviceName = "Dispositivo Sonoris";
  int _totalActiveTime = 0; // em segundos
  int _totalConversations = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Deletar conversas expiradas ao iniciar a tela
    _conversaService.deleteExpiredConversas();

    // Assine o estado de conexão para atualizar a UI
    _connStateSub = _manager.connectionStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _connState = state;
      });

      // Requisita informações do dispositivo quando conectar
      if (state == BluetoothConnectionState.connected) {
        // Delay para garantir que a characteristic esteja pronta
        Future.delayed(const Duration(milliseconds: 6000), () {
          _loadDeviceInfo();
        });
      }

      // Notifica o usuário quando o dispositivo for desconectado
      if (state == BluetoothConnectionState.disconnected &&
          _manager.connectedDevice != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.error('Dispositivo Sonoris desconectado'),
        );
      }
    });

    // Assine o stream de nome do dispositivo para atualizar quando mudar
    _deviceNameSub = _manager.deviceNameStream.listen((newName) {
      if (!mounted) return;
      setState(() {
        _deviceName = newName;
      });
    });

    // Se já estiver conectado ao carregar a tela, requisita device info
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_manager.connectedDevice != null &&
          _connState == BluetoothConnectionState.connected) {
        _loadDeviceInfo();
      }
    });
  }

  /// Requisita informações do dispositivo via BLE
  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = await _manager.requestDeviceInfo();

      if (deviceInfo == null) {
        debugPrint('Device info retornou null');
        return;
      }

      if (deviceInfo.isEmpty) {
        debugPrint('Device info está vazio');
        return;
      }

      if (mounted) {
        setState(() {
          _deviceName = deviceInfo['device_name'] ?? 'Sonoris Device';
          _totalActiveTime = deviceInfo['total_active_time'] ?? 0;
          _totalConversations = deviceInfo['total_conversations'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar device info: $e');
    }
  }

  /// Formata tempo ativo de segundos para horas
  String _formatActiveTime(int seconds) {
    if (seconds < 3600) {
      // Menos de 1 hora, mostra em minutos
      final minutes = (seconds / 60).round();
      return '${minutes}min';
    } else {
      // 1 hora ou mais, mostra em horas
      final hours = (seconds / 3600).round();
      return '${hours}h';
    }
  }

  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // ouça as mudanças do usuário (foto e nome) em tempo real
      _userStream =
          FirebaseFirestore.instance
              .collection("Usuario")
              .doc(user.uid)
              .snapshots();

      _userSub = _userStream!.listen((snapshot) {
        if (!mounted) return;
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final primeiroNome = (data['Nome'] ?? '').toString().split(' ').first;
          final foto = (data['Foto_url'] ?? '').toString();
          setState(() {
            _userName = primeiroNome;
            _photoUrl =
                (foto.isNotEmpty)
                    ? '$foto?v=${DateTime.now().millisecondsSinceEpoch}'
                    : null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _connStateSub?.cancel();
    _deviceNameSub?.cancel();
    _manager.onConversationsReceived = null;
    _manager.onConnectionEstablished = null;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 25,
            right: 25,
            top: 55,
            bottom: 30,
          ),
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // nome e foto do usuário
              Row(
                spacing: 10,
                children: [
                  CircleAvatar(
                    key: ValueKey(_photoUrl),
                    radius: 24,
                    backgroundImage: const AssetImage('assets/images/User.png'),
                    foregroundImage:
                        _photoUrl != null
                            ? CachedNetworkImageProvider(_photoUrl!)
                            : null,
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
                        ? Column(
                          spacing: 8,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // nome do dispositivo
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
                                      _deviceName,
                                      style: AppTextStyles.bold.copyWith(
                                        color: AppColors.white100,
                                      ),
                                    ),
                                  ],
                                ),

                                // bateria do dispositivo
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 6,
                                  children: [
                                    Text(
                                      isThisConnected
                                          ? 'Conectado'
                                          : 'Desconectado',
                                      style: AppTextStyles.body.copyWith(
                                        color:
                                            isThisConnected
                                                ? AppColors.teal500
                                                : AppColors.rose500,
                                      ),
                                    ),
                                    Container(
                                      height: 9,
                                      width: 9,
                                      decoration: BoxDecoration(
                                        color:
                                            isThisConnected
                                                ? AppColors.teal500
                                                : AppColors.rose500,
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              spacing: 8,
                              children: [
                                // quantidade de conversas
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Conversas',
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.blue200,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      '$_totalConversations',
                                      style: AppTextStyles.bold.copyWith(
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
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.blue200,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      _formatActiveTime(_totalActiveTime),
                                      style: AppTextStyles.bold.copyWith(
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

                  // card com as conversas do Firebase
                  StreamBuilder<List<ConversaNaoSalva>>(
                    stream: _conversaService.getConversasNaoSalvasStream(),
                    builder: (context, snapshot) {
                      // Mostra loading enquanto carrega
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          padding: const EdgeInsets.all(24),
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
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // Se não tem conversas
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
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
                            spacing: 10,
                            children: [
                              Text(
                                'Nenhuma conversa não salva',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.gray500,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              CustomButton(
                                text: 'Ver todas',
                                outlined: true,
                                fullWidth: false,
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed('/unsavedchats');
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      // Pega as 2 conversas mais recentes
                      final conversas = snapshot.data!.take(2).toList();

                      return Container(
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
                            // Mapeia as conversas
                            ...conversas.map((conversa) {
                              return GestureDetector(
                                onTap: () {
                                  // Navega para a tela de chat específica
                                  Navigator.of(context).pushNamed(
                                    '/unsavedchats/chat',
                                    arguments: conversa,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white100,
                                    border: Border.all(
                                      color: AppColors.gray300,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          conversa.nome,
                                          style: AppTextStyles.bold.copyWith(
                                            color: AppColors.gray900,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            conversa.data,
                                            style: AppTextStyles.medium,
                                          ),
                                          Text(
                                            '${conversa.horarioInicial} - ${conversa.horarioFinal}',
                                            style: AppTextStyles.medium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),

                            // button de ver todas
                            CustomButton(
                              text: 'Ver todas',
                              outlined: true,
                              fullWidth: false,
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushNamed('/unsavedchats');
                              },
                            ),
                          ],
                        ),
                      );
                    },
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
