import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sonoris/theme/colors.dart';

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
          title: const Text('Escolha uma cor'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: customColor,
              onColorChanged: (color) => customColor = color,
              enableAlpha: false,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                widget.onColorSelected(customColor);
                Navigator.of(context).pop();
              },
              child: const Text('Selecionar'),
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
          color: color,
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
        child: _buildCircleContent(color, index, isSelected),
      ),
    );
  }

  Widget _buildCircleContent(Color color, int index, bool isSelected) {
    if (index == 0 && widget.enableCustomPicker) {
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
            bool isSelected = widget.selectedColor == color;

            return _buildColorCircle(color, index, isSelected);
          }).toList(),
    );
  }
}
