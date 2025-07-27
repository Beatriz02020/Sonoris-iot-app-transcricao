import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sonoris/screens/main/home/unsaved_chat_screen.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

class ChatSelect extends StatelessWidget {
  final String nome;
  final String data;
  final String horarioInicial;
  final String horarioFinal;
  final String? image;
  final Widget? overlayIcon;

  const ChatSelect({
    super.key,
    required this.nome,
    required this.data,
    required this.horarioInicial,
    required this.horarioFinal,
    required this.image,
    required this.overlayIcon,
  });

  @override
  Widget build(BuildContext context) {
    final String imagePath = 'assets/images/icons/$image.png';

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
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                  // TODO arrumar os icones
                  Icon(
                    Icons.star,
                    color: AppColors.white100, // cor do contorno
                    size: 20,
                  ),
                  Icon(
                    Icons.star,
                    color: AppColors.amber500, // cor do preenchimento
                    size: 16,
                  ),
                ],
              ),

            if (image != null) const SizedBox(width: 10),
            Text(
              nome,
              style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
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
