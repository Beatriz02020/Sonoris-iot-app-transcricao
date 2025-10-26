import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

import 'customButton.dart';

class ColorSelector extends StatefulWidget {
  final List<Color> colors;
  final Color selectedColor;
  final Function(Color) onColorSelected;
  final bool enableCustomPicker;
  final double size;
  final double spacing;

  const ColorSelector({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
    this.enableCustomPicker = false,
    this.size = 40,
    this.spacing = 12,
  });

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  void _openColorPicker() {
    Color customColor = widget.selectedColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Escolha uma cor:'),
          titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.blue500),
          backgroundColor: AppColors.white100,
          contentPadding: const EdgeInsets.all(16),
          elevation: 0,
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: customColor,
              onColorChanged: (color) => customColor = color,
              enableAlpha: false,
              labelTypes: [],
              pickerAreaBorderRadius: BorderRadius.circular(8),
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            CustomButton(
              color: AppColors.rose500,
              fullWidth: true,
              text: 'Cancelar',
              onPressed: () => Navigator.of(context).pop(),
            ),
            CustomButton(
              text: 'Selecionar',
              fullWidth: true,
              onPressed: () {
                widget.onColorSelected(customColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorCircle(Color color, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (index == 0 && widget.enableCustomPicker) {
          _openColorPicker();
        } else {
          widget.onColorSelected(color);
        }
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color:
              (index == 0 && widget.enableCustomPicker && isSelected)
                  ? widget.selectedColor
                  : color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.gray900 : Colors.transparent,
            width: 2,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.gray300,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: _buildCircleContent(
          (index == 0 && widget.enableCustomPicker && isSelected)
              ? widget.selectedColor
              : color,
          index,
          isSelected,
        ),
      ),
    );
  }

  Widget _buildCircleContent(Color color, int index, bool isSelected) {
    // For the first swatch (custom picker): show the PNG icon when not selected,
    // but when selected, show the chosen custom color (handled by the container
    // background) and the selected check icon below.
    if (index == 0 && widget.enableCustomPicker && !isSelected) {
      return ClipOval(
        child: Image.asset('assets/images/icons/cores.png', fit: BoxFit.cover),
      );
    }

    if (isSelected) {
      return Center(
        child: Icon(
          Icons.check,
          color: color == AppColors.white100 ? AppColors.gray900 : Colors.white,
          size: 25,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      children:
          widget.colors.asMap().entries.map((entry) {
            int index = entry.key;
            Color color = entry.value;

            // Determine if current color is selected.
            // For the first swatch (index 0) when custom picker is enabled,
            // consider it selected when the widget.selectedColor isn't present
            // in the provided colors list — this indicates a custom color was
            // chosen via the picker.
            bool isSelected;
            if (index == 0 && widget.enableCustomPicker) {
              final contains = widget.colors.any(
                (c) => c.value == widget.selectedColor.value,
              );
              isSelected = !contains;
            } else {
              isSelected = widget.selectedColor.value == color.value;
            }

            return _buildColorCircle(color, index, isSelected);
          }).toList(),
    );
  }
}
