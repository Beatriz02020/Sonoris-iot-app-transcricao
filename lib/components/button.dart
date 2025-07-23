import 'package:flutter/material.dart';

import '../theme/colors.dart';

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
    final Color mainColor = color ?? Colors.blue.shade600;
    return SizedBox(
      width: 250,
      child: outlined
          ? OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: mainColor, width: 2),
          backgroundColor: AppColors.white100,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: mainColor, fontSize: 18),
        ),
      )
          : ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: AppColors.white100, fontSize: 18),
        ),
      ),
    );
  }
}