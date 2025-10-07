import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool outlined;
  final Color? color;
  final double? width;
  final bool fullWidth;
  final double? iconSize;

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

  // TODO Fazer o arrowCircleButton
  // TODO Arrumar o estilo do botão pressionado

  @override
  Widget build(BuildContext context) {
    final Color mainColor = color ?? AppColors.blue500;
    Widget button =
        outlined
            ? OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: mainColor, width: 1.5),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 6,
                    bottom: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: AppColors.blue50,
                  elevation: 0,
                  disabledForegroundColor: AppColors.gray500,
                  disabledBackgroundColor: AppColors.gray200,
                ),
                onPressed: onPressed,
                child: Text(
                  text,
                  style: AppTextStyles.bold.copyWith(
                    color: onPressed == null
                        ? AppColors.gray500
                        : AppColors.blue600,
                  ),
                ),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 6,
                    bottom: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor:
                      onPressed == null ? AppColors.gray300 : mainColor,
                  elevation: 0,
                  disabledBackgroundColor: AppColors.gray300,
                  disabledForegroundColor: AppColors.gray500,
                ),
                onPressed: onPressed,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          icon,
                          color: AppColors.white100,
                          size: iconSize ?? 25,
                        ),
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
