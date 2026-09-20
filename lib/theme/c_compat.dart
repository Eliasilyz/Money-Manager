// Compatibility shim — provides static color access for legacy code
import 'package:flutter/material.dart';
import 'app_colors.dart';

class C {
  static Color bg = AppColors.bg;
  static Color surface = AppColors.surface;
  static Color card = AppColors.card;
  static Color card2 = AppColors.card2;
  static Color gold = AppColors.gold;
  static Color gold2 = AppColors.gold2;
  static Color teal = AppColors.teal;
  static Color rose = AppColors.rose;
  static Color sky = AppColors.sky;
  static Color orange = AppColors.orange;
  static Color lilac = AppColors.lilac;
  static Color border = AppColors.border;
  static Color textPrimary = AppColors.textPrimary;
  static Color textMuted = AppColors.textMuted;
  static Color textDim = AppColors.textDim;
  static Color textDisabled = AppColors.textMuted;
  static Color emerald = AppColors.emerald;
  static Color coral = AppColors.coral;
  static Color violet = AppColors.violet;
  static Color blue = AppColors.blue;
  static Color amber = AppColors.amber;
}

extension AppColorsTheme on BuildContext {
  AppColorsT get colorsTheme => AppColorsT.of(this);
}
