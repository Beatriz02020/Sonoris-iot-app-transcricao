import 'package:flutter/material.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class AnswerCategoryButton extends StatelessWidget {
  final String text;
  final String? text2;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool outlined;
  final double? width;
  final bool fullWidth;

  const AnswerCategoryButton({
    super.key,
    required this.text,
    this.text2,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.width,
    this.fullWidth = false,
   });

  @override
  Widget build(BuildContext context) {
    Widget button = SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: AppColors.white100,
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(icon, color: AppColors.gray900, size: 20),
                    ),
                  Text(text, style: AppTextStyles.bold.copyWith(color: AppColors.gray900)),
                ],
              ),
              Row(
                spacing: 10,
                children: <Widget>[
                  if (text2 != null)
                    Text(
                        text2!,
                        style: AppTextStyles.medium.copyWith(color: AppColors.gray500)),
                  const Icon(Icons.drag_indicator_rounded,
                      color: AppColors.gray500, size: 25),

                ],
              ),
            ],
          )),
    );
    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    } else if (width != null) {
      return SizedBox(width: width, child: button);
    } else {
      return button; // tamanho natural do texto
    }
  }
}
