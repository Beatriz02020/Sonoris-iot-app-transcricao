import 'package:flutter/material.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class AnswerCategoryButton extends StatelessWidget {
  final String title;
  final String? answerAmount;
  final VoidCallback onPressed;
  final VoidCallback? onIconPressed; // ação no ícone principal (ex: deletar)
  final VoidCallback?
  onDragIconPressed; // ação no ícone de arrastar (ex: editar)
  final IconData? icon;
  final bool outlined;
  final double? width;

  const AnswerCategoryButton({
    super.key,
    required this.title,
    this.answerAmount,
    required this.onPressed,
    this.onIconPressed,
    this.onDragIconPressed,
    this.icon,
    this.outlined = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: AppColors.white100,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.031, // ~12px
        ),
        elevation: 0,
      ),

      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (icon != null)
                GestureDetector(
                  onTap: onIconPressed,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(icon, color: AppColors.gray900, size: 20),
                  ),
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
                ),
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
              GestureDetector(
                onTap: onDragIconPressed,
                child: const Icon(
                  Icons.drag_indicator_rounded,
                  color: AppColors.gray500,
                  size: 25,
                ),
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
