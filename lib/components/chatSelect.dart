import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sonoris/screens/main/home/unsaved_chat_screen.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

class ChatSelect extends StatelessWidget {
  final String nome;
  final String? descricao;
  final String data;
  final String horarioInicial;
  final String horarioFinal;
  final String? image;
  final bool favorito;


  const ChatSelect({
    super.key,
    required this.nome,
    required this.data,
    required this.horarioInicial,
    required this.horarioFinal,
    this.descricao,
    this.image,
    this.favorito = false,

  });

  @override
  Widget build(BuildContext context) {
    final String imagePath = 'assets/images/icons/$image.png';

    String limitarDescricao(String text, [int maxLength = 18]) {
      return (text.length <= maxLength) ? text : '${text.substring(0, maxLength)}...';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UnsavedChatScreen()),
        );
      },

      // respostas rápidas
      child: Container(
        // borda
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            //caso tenha imagem
            if (image != null)

              Stack(
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                  // TODO colocar limite de caracteres no titulo

                  if (favorito != false)
                    Positioned(
                      bottom: -4,
                      left: 25,
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
                  nome,
                  style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
                ),

                // Se tiver descrição, mostra
                if (descricao != null)
                  Text(
                    limitarDescricao(descricao!),
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,                        // Limita a 1 linha
                    overflow: TextOverflow.ellipsis,   // Adiciona "..."
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(data, style: AppTextStyles.medium),
                Text(
                  '$horarioInicial - $horarioFinal',
                  style: AppTextStyles.medium,
                ),


              ],
            ),
          ],
        ),
      ),
    );
  }
}
