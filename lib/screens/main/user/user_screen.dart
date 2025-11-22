import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sonoris/components/customButton.dart';
import 'package:sonoris/components/customTextField.dart';
import 'package:sonoris/services/auth_service.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController =
      TextEditingController(); // Novo controller para email

  String _userName = ""; // nome do usuário
  String? _photoUrl; // url da foto do usuário
  String? _bannerUrl; // url do banner do usuário
  bool _updatingPhoto = false;
  bool _updatingBanner = false;
  final _birthDateFormatter = _BirthDateInputFormatter();
  
  Stream<DocumentSnapshot>? _userStream;
  StreamSubscription<DocumentSnapshot>? _userStreamSub;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Busca dados de usuários logados
  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Cancelar listener anterior se existir
      _userStreamSub?.cancel();
      
      // Configurar listener em tempo real
      _userStream = FirebaseFirestore.instance
          .collection("Usuario")
          .doc(user.uid)
          .snapshots();
      
      _userStreamSub = _userStream!.listen((snapshot) async {
        if (!mounted) return;

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>?;
          if (data == null) return;

          final nomeCompleto = (data['Nome'] ?? '').toString();
          final primeiroNome = nomeCompleto.split(' ').first;
          final dataNasc = (data['DataNasc'] ?? '').toString();

          final foto = (data['Foto_url'] ?? '').toString();
          final banner = (data['banner_url'] ?? '').toString();

          // Debug prints to help trace updates
          debugPrint('[UserScreen] snapshot received. foto: $foto, banner: $banner');

          // Evict cached images for the raw URLs (without our cache-busting param)
          if (foto.isNotEmpty) {
            try {
              await NetworkImage(foto).evict();
              try {
                await DefaultCacheManager().removeFile(foto);
              } catch (e) {
                debugPrint('[UserScreen] failed to removeFile foto from cache manager: $e');
              }
            } catch (e) {
              debugPrint('[UserScreen] failed to evict foto cache: $e');
            }
          }
          if (banner.isNotEmpty) {
            try {
              await NetworkImage(banner).evict();
              try {
                await DefaultCacheManager().removeFile(banner);
              } catch (e) {
                debugPrint('[UserScreen] failed to removeFile banner from cache manager: $e');
              }
            } catch (e) {
              debugPrint('[UserScreen] failed to evict banner cache: $e');
            }
          }

          setState(() {
            _userName = primeiroNome;
            _nameController.text = nomeCompleto;
            _birthDateController.text = dataNasc;
            _emailController.text = user.email ?? ''; // Preenche o email

            _photoUrl = (foto.isNotEmpty)
                ? '$foto?v=${DateTime.now().millisecondsSinceEpoch}'
                : null;
            _bannerUrl = (banner.isNotEmpty)
                ? '$banner?v=${DateTime.now().millisecondsSinceEpoch}'
                : null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _userStreamSub?.cancel();
    _nameController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadBanner() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _updatingBanner = true;
    });
    try {
      final url = await AuthService().updateBannerPhoto(File(picked.path));
      if (!mounted) return;
      debugPrint('[UserScreen] banner upload returned url: $url');
      try {
        await NetworkImage(url).evict();
        try {
          await DefaultCacheManager().removeFile(url);
        } catch (e) {
          debugPrint('[UserScreen] failed to removeFile banner (post-upload): $e');
        }
      } catch (e) {
        debugPrint('[UserScreen] failed to evict banner (post-upload): $e');
      }
      setState(() {
        _bannerUrl = '$url?v=${DateTime.now().millisecondsSinceEpoch}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.blue500,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          content: const Text(
            'Banner atualizado com sucesso!',
            style: TextStyle(color: AppColors.white100),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.rose500,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          content: Text(
            'Falha ao atualizar banner: $e',
            style: const TextStyle(color: AppColors.white100),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingBanner = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    debugPrint('[UserScreen] 📸 _pickAndUploadPhoto INICIADO');
    final picker = ImagePicker();
    debugPrint('[UserScreen] 📸 Abrindo galeria...');
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    debugPrint('[UserScreen] 📸 Imagem selecionada: ${picked?.path}');
    if (picked == null) {
      debugPrint('[UserScreen] ❌ Nenhuma imagem selecionada');
      return;
    }
    setState(() {
      _updatingPhoto = true;
    });
    debugPrint('[UserScreen] 📸 Iniciando upload para Cloudinary...');
    try {
      final url = await AuthService().updateProfilePhoto(File(picked.path));
      if (!mounted) return;
      debugPrint('[UserScreen] ✅ photo upload returned url: $url');
      try {
        await NetworkImage(url).evict();
        try {
          await DefaultCacheManager().removeFile(url);
        } catch (e) {
          debugPrint('[UserScreen] failed to removeFile photo (post-upload): $e');
        }
      } catch (e) {
        debugPrint('[UserScreen] failed to evict photo (post-upload): $e');
      }
      setState(() {
        _photoUrl = '$url?v=${DateTime.now().millisecondsSinceEpoch}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.blue500,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          content: const Text(
            'Foto atualizada com sucesso!',
            style: TextStyle(color: AppColors.white100),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.rose500,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          content: Text(
            'Falha ao atualizar foto: $e',
            style: const TextStyle(color: AppColors.white100),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingPhoto = false;
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
                  GestureDetector(
                    onTap: _updatingBanner ? null : _pickAndUploadBanner,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          color: AppColors.blue200,
                          width: double.infinity,
                          height: 180,
                          child: ClipRRect(
                              child: _bannerUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: _bannerUrl!,
                                      key: ValueKey(_bannerUrl),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: AppColors.blue200,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Image.asset(
                                        'assets/images/BannerPerfil.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/BannerPerfil.jpg',
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                        if (_updatingBanner)
                          Container(
                            height: 180,
                            color: Colors.black26,
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.white100,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: MediaQuery.of(context).size.width / 2 - 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            debugPrint('[UserScreen] 👆 Avatar clicado! _updatingPhoto=$_updatingPhoto');
                            if (!_updatingPhoto) {
                              _pickAndUploadPhoto();
                            }
                          },
                          child: CircleAvatar(
                            key: ValueKey(_photoUrl),
                            radius: 50,
                            backgroundImage: const AssetImage(
                              'assets/images/User.png',
                            ),
                            foregroundImage: _photoUrl != null
                                ? CachedNetworkImageProvider(_photoUrl!)
                                : null,
                          ),
                        ),
                        if (_updatingPhoto)
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.white100,
                                ),
                              ),
                            ),
                          ),
                      ],
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
                  spacing: 45,
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
                                  (ano % 4 == 0 &&
                                          (ano % 100 != 0 || ano % 400 == 0))
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
                          ],
                        ),
                        // Email (desativado)
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
                              controller: _emailController,
                              enabled: false, // Desativa edição
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      spacing: 2,
                      children: [
                        Text(
                          'Para alterar foto ou banner, clique sobre eles.',
                          style: AppTextStyles.medium.copyWith(
                            fontSize: 15,
                            color: AppColors.gray700,
                          ),
                          textAlign: TextAlign.center,
                        ),

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
                                    });
                                // Atualiza o nome exibido no topo após salvar
                                final nomeCompleto = _nameController.text;
                                final primeiroNome =
                                    nomeCompleto.split(' ').first;
                                setState(() {
                                  _userName = primeiroNome;
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
                            await FirebaseAuth.instance
                                .signOut(); // Desconecta o usuário
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushReplacementNamed(
                              '/initial',
                            ); // Redireciona para a tela inicial
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
