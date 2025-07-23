import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool outlined;
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.outlined = false,
    this.color,
  });

  // TODO Fazer os outros botoes

  @override
  Widget build(BuildContext context) {
    final Color mainColor = color ?? AppColors.blue500;
    return SizedBox(
      width: 250,
      child: outlined
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
        child: Text(
          text,
          style: AppTextStyles.bold.copyWith(color: AppColors.white100),
        ),
      ),
    );
  }
}