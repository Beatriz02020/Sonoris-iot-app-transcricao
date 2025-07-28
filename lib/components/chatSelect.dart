import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sonoris/screens/main/home/unsaved_chat_screen.dart';

import '../screens/main/savedChats/saved_chat_screen.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class ChatSelect extends StatelessWidget {
  final String nome;
  final String? descricao;
  final String data;
  final String horarioInicial;
  final String horarioFinal;
  final String? image;
  final bool salvas;
  final bool favorito;

  const ChatSelect({
    super.key,
    required this.nome,
    required this.data,
    required this.horarioInicial,
    required this.horarioFinal,
    this.descricao,
    this.image,
    this.salvas = false,
    this.favorito = false,
  });


  @override
  Widget build(BuildContext context) {
    final String imagePath = 'assets/images/icons/$image.png';

    String limitarTexto(String text, {int maxLength = 20}) {
      return (text.length <= maxLength) ? text : '${text.substring(0, maxLength)}...';
    }

    return GestureDetector(
      onTap: () {
            Navigator.of(context).pushNamed(salvas != false
                ? '/chat'
                : '/unsavedchats/chat');
      },

      // respostas rápidas
      child: Container(
        // borda
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white100,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray900.withAlpha(18),
              blurRadius: 18.5,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 10,
              children: [
                //caso tenha imagem
                if (image != null)

                  Stack(
                    children: [
                      Image.asset(
                        height: 53,
                        width: 53,
                        imagePath,
                        fit: BoxFit.cover,
                      ),

                      if (favorito != false)
                        Positioned(
                          bottom: -4,
                          left: 30,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                            ),
                            child:  Image.asset(
                              'assets/images/icons/Estrela.png',
                            ),
                          ),
                        ),
                    ],
                  ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      limitarTexto(nome, maxLength: 18),
                      maxLines: 1,
                      style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
                    ),

                    // Se tiver descrição, mostra
                    if (descricao != null)
                      Text(
                        limitarTexto(descricao!),
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,                        // Limita a 1 linha
                        overflow: TextOverflow.ellipsis,   // Adiciona "..."
                      ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(data, style: AppTextStyles.medium.copyWith(color: AppColors.gray500)),
                Text(
                  '$horarioInicial - $horarioFinal',
                  style: AppTextStyles.medium.copyWith(color: AppColors.gray500),
                ),


              ],
            ),
          ],
        ),
      ),
    );
  }
}
