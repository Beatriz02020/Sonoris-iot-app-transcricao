import 'package:flutter/material.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isDropdown;
  final List<String>? dropdownOptions;
  final String? selectedValue;
  final void Function(String?)? onChanged;
  final bool fullWidth;

  const CustomTextField({
    super.key,
    this.hintText = '',
    this.isDropdown = false,
    this.dropdownOptions,
    this.selectedValue,
    this.onChanged,
    this.fullWidth = false,
  }) : assert(
         isDropdown == false ||
             (dropdownOptions != null && dropdownOptions.length > 0),
         'Para usar como dropdown, forneça ao menos uma opção em dropdownOptions.',
       );

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder customBorder() {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.blue500, width: 1.5),
      );
    }

    Widget field =
        isDropdown
            ? DropdownButtonFormField<String>(
              value: selectedValue ?? dropdownOptions!.first,
              decoration: InputDecoration(
                border: customBorder(),
                enabledBorder: customBorder(),
                focusedBorder: customBorder(),
                hintStyle: AppTextStyles.body,
                hintText: hintText,
                contentPadding: const EdgeInsets.only(left: 15, top: 0),
              ),
              items:
                  dropdownOptions!
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
              onChanged: onChanged,
            )
            : TextField(
              style: AppTextStyles.body.copyWith(color: AppColors.gray900),
              decoration: InputDecoration(
                border: customBorder(),
                enabledBorder: customBorder(),
                focusedBorder: customBorder(),
                hintStyle: AppTextStyles.body,
                hintText: hintText,
                contentPadding: const EdgeInsets.only(top: 0, left: 15),
              ),
            );

    return fullWidth ? SizedBox(width: double.infinity, child: field) : field;
  }
}
