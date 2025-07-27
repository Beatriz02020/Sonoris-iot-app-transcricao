import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

// TODO muda o nome do arquivo

class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool outlined;
  final Color? color;
  final double? width; // <- Novo parâmetro
  final bool fullWidth;
  final double? iconSize; // <- Nova variável para controlar o tamanho do ícone

  const CustomButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.outlined = false,
    this.color,
    this.width, // <- Aqui também
    this.fullWidth = false, // valor padrão é false
    this.iconSize, // <- Adicionado ao construtor
  });

  // TODO Fazer os outros botoes

  @override
  Widget build(BuildContext context) {
    final Color mainColor = color ?? AppColors.blue500;
    Widget button =
    outlined
        ? OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: mainColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: AppColors.blue50,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyles.bold.copyWith(color: AppColors.blue600),
      ),
    )
        : ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: mainColor,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min, // Adicionado para ajustar o tamanho ao conteúdo
        children: <Widget>[
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(icon, color: AppColors.white100, size: iconSize ?? 25), // Usa iconSize se fornecido, senão 25
            ),
          Text(
            text,
            style: AppTextStyles.bold.copyWith(
              color: AppColors.white100,
            ),
          ),
        ],
      ),
    );

    // Agora decidimos o tamanho com base nos parâmetros:
    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    } else if (width != null) {
      return SizedBox(width: width, child: button);
    } else {
      return button; // tamanho natural do texto
    }
  }
}
