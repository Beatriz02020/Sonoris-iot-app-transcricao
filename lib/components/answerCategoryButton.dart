import 'package:flutter/material.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class AnswerCategoryButton extends StatelessWidget {
  final String title;
  final String? answerAmount;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool outlined;
  final double? width;

  const AnswerCategoryButton({
    super.key,
    required this.title,
    this.answerAmount,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.width,
  });

  // TODO Arrumar o estilo do botão pressionado
  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: AppColors.white100,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        elevation: 0,
      ),

      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(icon, color: AppColors.gray900, size: 20),
                ),
              Text(
                title,
                style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
              ),
            ],
          ),
          Row(
            spacing: 10,
            children: <Widget>[
              if (answerAmount != null)
                Text(
                  answerAmount!,
                  style: AppTextStyles.medium.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              const Icon(
                Icons.drag_indicator_rounded,
                color: AppColors.gray500,
                size: 25,
              ),
            ],
          ),
        ],
      ),
    );
    if (width != null) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.gray900.withAlpha(18),
              blurRadius: 18.5,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        width: width,
        child: button,
      );
    } else {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.gray900.withAlpha(18),
              blurRadius: 18.5,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        width: double.infinity,
        child: button,
      );
    }
  }
}
