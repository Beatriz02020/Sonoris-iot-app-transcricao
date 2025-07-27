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
  // final Widget onPressed;  TODO adicionar quando tiver backend

  const ChatSelect({
    super.key,
    required this.nome,
    required this.data,
    required this.horarioInicial,
    required this.horarioFinal,
    // required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
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
