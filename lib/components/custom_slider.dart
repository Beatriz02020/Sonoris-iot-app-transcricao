import 'package:flutter/material.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class CustomSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String? valueLabel;
  const CustomSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
        ),
        Column(
          children: [
            Slider(
              value: value,
              min: min,
              max: max,
              activeColor: AppColors.blue500,
              inactiveColor: AppColors.white100,
              onChanged: onChanged,
            ),

            Text(
              valueLabel ?? value.round().toString(),
              style: AppTextStyles.medium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
