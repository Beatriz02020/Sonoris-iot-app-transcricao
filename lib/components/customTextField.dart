import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonoris/theme/colors.dart';
import 'package:sonoris/theme/text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isSearch;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final void Function(String?)? onChanged;
  final bool fullWidth;
  final double verticalPadding;
  final bool obscureText;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.hintText = '',
    this.isSearch = false,
    this.validator,
    this.controller,
    this.keyboardType,
    this.onChanged,
    this.fullWidth = false,
    this.verticalPadding = 0.0,
    this.obscureText = false,
    this.suffixIcon,
    this.inputFormatters,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTall = verticalPadding > 24; // heurística para campo "alto"
    final double tallBottomPad = math.max(7.0, verticalPadding * 2 - 7);
    OutlineInputBorder customBorder() {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: isSearch ? AppColors.gray500 : AppColors.blue500,
          width: 1.5,
        ),
      );
    }

    Widget field = TextFormField(
      keyboardType: keyboardType,
      validator: validator,
      controller: controller,
      style: AppTextStyles.body.copyWith(color: AppColors.gray900),
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      enabled: enabled,
      maxLines: 1,
      textAlignVertical:
          verticalPadding > 10
              ? TextAlignVertical.top
              : TextAlignVertical.center,
      decoration: InputDecoration(
        border: customBorder(),
        enabledBorder: customBorder(),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.blue300, width: 1.5),
        ),
        focusedBorder: customBorder(),
        hintStyle: AppTextStyles.body,
        hintText: hintText,
        hintMaxLines: 10,
        prefixIcon:
            isSearch // icone do input de pesquisa
                ? Icon(Icons.search, color: AppColors.gray500, size: 20)
                : null,
        suffixIcon: suffixIcon,
        contentPadding:
            isTall
                ? EdgeInsets.fromLTRB(15, 7, 15, tallBottomPad)
                : EdgeInsets.symmetric(
                  vertical: verticalPadding,
                  horizontal: 15,
                ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: field) : field;
  }
}
