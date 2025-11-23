import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sonoris/components/customDivider.dart';
import 'package:sonoris/components/customSnackBar.dart';
import 'package:sonoris/models/conversa.dart';
import 'package:sonoris/services/conversa_service.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import '../../../components/customButton.dart';
import '../../../components/messageBubble.dart';

class SavedChatScreen extends StatefulWidget {
  final ConversaSalva conversa;

  const SavedChatScreen({super.key, required this.conversa});

  @override
  State<SavedChatScreen> createState() => _SavedChatScreenState();
}

class _SavedChatScreenState extends State<SavedChatScreen> {
  final ConversaService _conversaService = ConversaService();
  late ConversaSalva _conversa; // Estado local da conversa

  // TODO: Fazer o botão de scrollar para cima e para baixo
  @override
  void initState() {
    _conversa = widget.conversa; // Inicializar com a conversa passada
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
    // Usar o estado local ao invés do widget.conversa
    final conversa = _conversa;

    // Usar o getter que normaliza o nome da categoria
    final String iconPath =
        'assets/images/icons/${conversa.categoriaNormalizada}.png';

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
            Expanded(
              child: Row(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Stack(
                    children: [
                      Image.asset(
                        height: 53,
                        width: 53,
                        iconPath,
                        fit: BoxFit.cover,
                      ),
                      if (conversa.favorito)
                        Positioned(
                          bottom: -4,
                          left: 25,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            child: Image.asset(
                              'assets/images/icons/Estrela.png',
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(conversa.nome, overflow: TextOverflow.ellipsis),
                        Text(
                          '${conversa.data}, ${conversa.horarioInicial} - ${conversa.horarioFinal}',
                          style: AppTextStyles.light.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        padding: const EdgeInsets.only(left: 45, top: 0, right: 45, bottom: 15),
        decoration: BoxDecoration(color: AppColors.white100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () async {
                // Confirmar deleção
                final confirmar = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Deletar conversa'),
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
                  final sucesso = await _conversaService.deleteConversaSalva(
                    conversa.id,
                  );
                  if (sucesso && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBar.success('Conversa excluída com sucesso'),
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
                    "Deletar",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.rose500,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                // Navegar para tela de edição
                await Navigator.pushNamed(
                  context,
                  '/savedchats/chat/editing',
                  arguments: _conversa,
                );

                // Sempre atualizar conversa do Firebase ao voltar
                if (mounted) {
                  final conversaAtualizada = await _conversaService
                      .getConversaSalvaById(_conversa.id);

                  if (conversaAtualizada != null && mounted) {
                    setState(() {
                      _conversa = conversaAtualizada;
                    });
                  }
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 4,
                children: [
                  Icon(Icons.edit_rounded, color: AppColors.blue500, size: 40),
                  Text(
                    "Editar",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.blue500,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                // Toggle favorito
                final novoEstado = !_conversa.favorito;
                final sucesso = await _conversaService.updateConversaSalva(
                  conversaId: _conversa.id,
                  favorito: novoEstado,
                );

                if (sucesso && mounted) {
                  // Atualizar estado local sem voltar à tela anterior
                  setState(() {
                    _conversa = ConversaSalva(
                      id: _conversa.id,
                      nome: _conversa.nome,
                      descricao: _conversa.descricao,
                      categoria: _conversa.categoria,
                      favorito: novoEstado,
                      createdAt: _conversa.createdAt,
                      dataConversa: _conversa.dataConversa,
                      lines: _conversa.lines,
                    );
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    CustomSnackBar.success(
                      novoEstado
                          ? 'Adicionado aos favoritos'
                          : 'Removido dos favoritos',
                    ),
                  );
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 4,
                children: [
                  Icon(
                    _conversa.favorito ? Icons.star : Icons.star_border,
                    color: AppColors.amber500,
                    size: 40,
                  ),
                  Text(
                    "Favorito",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.amber500,
                    ),
                  ),
                ],
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
                        ...conversa.lines.map((linha) {
                          return Messagebubble(
                            texto: linha.text,
                            horario: linha.horario,
                          );
                        }),

                        // Mostrar descrição se houver
                        if (conversa.descricao.isNotEmpty) ...[
                          CustomDivider(),
                          Text(
                            conversa.descricao,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.gray700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
