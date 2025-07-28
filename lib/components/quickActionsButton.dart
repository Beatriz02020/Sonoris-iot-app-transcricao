import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

class QuickActionsButton extends StatelessWidget {
  final String icon;
  final String text;
  final Function onPressed;

  const QuickActionsButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String iconPath = 'assets/images/icons/$icon.png';

    return GestureDetector(
      onTap: () => onPressed(),

      // respostas rápidas
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray900.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        // icon e titulo
        child: Column(
          spacing: 6,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(iconPath), // icone
            Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(height: 1.2),
            ), // texto
          ],
        ),
      ),
    );
  }
}
