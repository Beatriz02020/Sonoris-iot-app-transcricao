import 'package:flutter/cupertino.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

class Messagebubble extends StatelessWidget {
  final String texto;
  final String horario;
  final bool isBlue;

  const Messagebubble({
    super.key,
    required this.texto,
    required this.horario,
    this.isBlue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        spacing: 5,
        crossAxisAlignment: isBlue ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isBlue ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isBlue ? AppColors.blue600 : AppColors.white100,
                  borderRadius: BorderRadius.only(
                    topLeft: isBlue ? Radius.circular(16) : Radius.zero,
                    topRight: isBlue ? Radius.zero : Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gray900.withAlpha(18),
                      blurRadius: 18.5,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(texto, style: AppTextStyles.body.copyWith(color: isBlue ?  AppColors.white100 : AppColors.gray700)),
              ),
            ],
          ),

          Text(horario, style: AppTextStyles.light.copyWith(color: AppColors.gray700)),
        ]
    );
  }
}