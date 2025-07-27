import 'package:flutter/material.dart';
import 'colors.dart';

// TODO arrumar isso

class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontFamily: 'RubikVariavel',
    fontSize: 40,
    color: AppColors.gray700,
    fontVariations: <FontVariation>[FontVariation('wght', 800.00)],
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'RubikVariavel',
    fontSize: 30,
    color: AppColors.gray700,
    fontVariations: <FontVariation>[FontVariation('wght', 600.00)],
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'RubikVariavel',
    fontSize: 22,
    color: AppColors.gray700,
    fontVariations: <FontVariation>[FontVariation('wght', 600.00)],
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: 'RubikVariavel',
    fontSize: 18,
    color: AppColors.gray700,
    fontVariations: <FontVariation>[FontVariation('wght', 600.00)],
  );

  // Texto padrão (corpo)

  static const TextStyle bold = TextStyle(
    fontFamily: 'SourceSans3Variavel',
    fontSize: 16,
    color: AppColors.gray700,
    fontVariations: <FontVariation>[FontVariation('wght', 700.00)],
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'SourceSans3Variavel',
    fontSize: 16,
    color: AppColors.gray700,
    fontVariations: <FontVariation>[FontVariation('wght', 600.00)],
  );

  static const TextStyle medium = TextStyle(
    fontFamily: 'SourceSans3Variavel',
    fontSize: 16,
    color: AppColors.gray700,
    fontVariations: <FontVariation>[FontVariation('wght', 500.00)],
  );

  static const TextStyle light = TextStyle(
    fontFamily: 'SourceSans3Variavel',
    fontSize: 16,
    color: AppColors.gray700,
    fontVariations: <FontVariation>[FontVariation('wght', 400.00)],
  );

  static const TextStyle boldSmall = TextStyle(
    fontFamily: 'SourceSans3Variavel',
    fontSize: 14,
    color: AppColors.gray700,
    fontVariations: <FontVariation>[FontVariation('wght', 700.00)],
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'SourceSans3Variavel',
    fontSize: 14,
    color: AppColors.gray700,
    fontVariations: <FontVariation>[FontVariation('wght', 600.00)],
  );
}
