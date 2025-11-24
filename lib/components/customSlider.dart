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
  final double? step;

  const CustomSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.valueLabel,
    this.step,
  });

  bool get _isIntRange => min % 1 == 0 && max % 1 == 0;

  int get _divisions {
    if (step != null) {
      return ((max - min) / step!).round();
    }
    if (_isIntRange) {
      return (max - min).toInt();
    }
    return 100;
  }

  String get _defaultValueLabel {
    if (valueLabel != null) return valueLabel!;

    if (_isIntRange && step == null) {
      return value.round().toString();
    }

    if (step != null && step! >= 1) {
      return value.round().toString();
    }

    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Text(
          label,
          style: AppTextStyles.bold.copyWith(color: AppColors.gray900),
        ),
        Column(
          spacing: 0,
          children: [
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: _divisions,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              activeColor: AppColors.blue500,
              inactiveColor: AppColors.white100,
              onChanged: (newValue) {
                double adjustedValue = newValue;

                if (step != null) {
                  // Arredondar para o step mais próximo
                  adjustedValue = (newValue / step!).round() * step!;
                  // Garantir que está dentro dos limites
                  adjustedValue = adjustedValue.clamp(min, max);
                } else if (_isIntRange) {
                  // Se é range inteiro sem step, arredondar para inteiro
                  adjustedValue = newValue.roundToDouble();
                }

                onChanged(adjustedValue);
              },
            ),

            Text(
              _defaultValueLabel,
              style: AppTextStyles.medium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
