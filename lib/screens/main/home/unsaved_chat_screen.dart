import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../components/messageBubble.dart';

class UnsavedChatScreen extends StatefulWidget {
  const UnsavedChatScreen({super.key});

  @override
  State<UnsavedChatScreen> createState() => _UnsavedChatScreenState();
}

class _UnsavedChatScreenState extends State<UnsavedChatScreen> {
  // TODO Descobrir um jeito melhor de trocar a cor quando entrar nessa página
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: AppColors.white100,
          systemNavigationBarColor: AppColors.white100,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white100,
        iconTheme: const IconThemeData(color: AppColors.gray900),
        toolbarHeight: 75,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading:
            false, // desativa o ícone de voltar automático
        titleTextStyle: AppTextStyles.bold.copyWith(color: AppColors.gray900),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => {Navigator.of(context).pushNamed('/')},
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Conversa_04_07_25_8h'),
                    Text(
                      '04/07/2025, 08:30 - 11:30',
                      style: AppTextStyles.light.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        padding: const EdgeInsets.only(left: 65, top: 0, right: 65, bottom: 15),
        decoration: BoxDecoration(color: AppColors.white100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 6,
              children: [
                SvgPicture.asset(
                  "assets/images/XIcon.svg",
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    AppColors.rose500,
                    BlendMode.srcIn,
                  ),
                ),
                Text(
                  "Deletar Conversa",
                  style: AppTextStyles.body.copyWith(color: AppColors.rose500),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 4,
              children: [
                SvgPicture.asset(
                  "assets/images/SavedFill.svg",
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    AppColors.blue500,
                    BlendMode.srcIn,
                  ),
                ),
                Text(
                  "Salvar",
                  style: AppTextStyles.body.copyWith(color: AppColors.blue500),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 12, // (55)
              bottom: 30,
            ),
            child: Column(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // chat
                Messagebubble(texto: 'Texto', horario: '8:30:32', isBlue: true),
                Messagebubble(texto: 'Texto', horario: '8:30:46'),
                Messagebubble(texto: 'Texto', horario: '8:30:52'),
                Messagebubble(texto: 'Texto', horario: '8:30:59'),
                Messagebubble(texto: 'Texto', horario: '8:31:12'),
                Messagebubble(texto: 'Texto', horario: '8:31:21'),
                Messagebubble(texto: 'Texto', horario: '8:31:34', isBlue: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
