import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sonoris/models/conversa.dart';
import 'package:sonoris/services/conversa_service.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../components/customButton.dart';
import '../../../components/messageBubble.dart';

class UnsavedChatScreen extends StatefulWidget {
  final ConversaNaoSalva conversa;

  const UnsavedChatScreen({super.key, required this.conversa});

  @override
  State<UnsavedChatScreen> createState() => _UnsavedChatScreenState();
}

class _UnsavedChatScreenState extends State<UnsavedChatScreen> {
  final ConversaService _conversaService = ConversaService();
  // TODO: Fazer o botão de scrollar para cima e para baixo
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
    final conversa = widget.conversa;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white100,
        iconTheme: const IconThemeData(color: AppColors.gray900),
        toolbarHeight: 75,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleTextStyle: AppTextStyles.bold.copyWith(color: AppColors.gray900),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(conversa.nome),
                    Text(
                      '${conversa.data}, ${conversa.horarioInicial} - ${conversa.horarioFinal}',
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
        padding: const EdgeInsets.only(left: 40, top: 0, right: 40, bottom: 15),
        decoration: BoxDecoration(color: AppColors.white100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 130,
              child: GestureDetector(
                onTap: () async {
                  // Confirmar deleção
                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Deletar conversa'),
                          titleTextStyle: AppTextStyles.h3.copyWith(
                            color: AppColors.blue500,
                          ),
                          backgroundColor: AppColors.white100,
                          contentPadding: const EdgeInsets.all(16),
                          elevation: 0,
                          content: const Text(
                            'Tem certeza que deseja deletar esta conversa? Esta ação não pode ser desfeita.',
                          ),
                          actions: [
                            CustomButton(
                              text: 'Cancelar',
                              fullWidth: true,
                              color: AppColors.rose500,
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            CustomButton(
                              text: 'Deletar',
                              fullWidth: true,
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        ),
                  );

                  if (confirmar == true && mounted) {
                    final sucesso = await _conversaService.deleteConversa(
                      conversa.id,
                    );
                    if (sucesso && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Conversa deletada com sucesso'),
                        ),
                      );
                    }
                  }
                },
                child: Column(
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
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.rose500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 130,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamed('/unsavedchats/chat/saving', arguments: conversa);
                },
                child: Column(
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
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.blue500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body:
          conversa.lines.isEmpty
              ? Center(
                child: Text(
                  'Esta conversa não possui linhas',
                  style: AppTextStyles.body.copyWith(color: AppColors.gray500),
                ),
              )
              : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                      right: 30,
                      top: 12,
                      bottom: 30,
                    ),
                    child: Column(
                      spacing: 12,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exibir todas as linhas da conversa
                        ...conversa.lines.asMap().entries.map((entry) {
                          final linha = entry.value;
                          return Messagebubble(
                            texto: linha.text,
                            horario: linha.horario,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
