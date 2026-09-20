import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const bg = Color(0xFF070B18);
  static const surface = Color(0xFF0B1022);
  static const card = Color(0xFF0F1630);
  static const card2 = Color(0xFF141D3A);
  static const gold = Color(0xFFF4C430);
  static const gold2 = Color(0xFFE8A800);
  static const teal = Color(0xFF22D4A6);
  static const rose = Color(0xFFFF4757);
  static const sky = Color(0xFF5E9BFF);
  static const orange = Color(0xFFFF9F43);
  static const lilac = Color(0xFFA78BFA);
  static const textPrimary = Color(0xFFEEF0FB);
  static const textMuted = Color(0x6BEEF0FB);
  static const textDim = Color(0x38EEF0FB);
  static const border = Color(0x12FFFFFF);
  static const emerald = teal;
  static const coral = rose;
  static const violet = lilac;
  static const blue = sky;
  static const amber = orange;
}

@immutable
class AppColorsT extends ThemeExtension<AppColorsT> {
  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;
  final Color primaryDark;
  final Color navBackground;
  final Color income;
  final Color expense;
  final Color heroCard;

  const AppColorsT({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.primaryDark,
    required this.navBackground,
    required this.income,
    required this.expense,
    required this.heroCard,
  });

  static const light = AppColorsT(
    background: Color(0xFFF4F6F5),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    border: Color(0xFFE6EBE8),
    textPrimary: Color(0xFF1A1F1C),
    textSecondary: Color(0xFF7A857F),
    primary: Color(0xFF1B6E4B),
    primaryDark: Color(0xFF0F5A3C),
    navBackground: Color(0xFF0E3B2B),
    income: Color(0xFF1F7A4D),
    expense: Color(0xFFE0524A),
    heroCard: Color(0xFF0F5A3C),
  );

  static const dark = AppColorsT(
    background: Color(0xFF0E1411),
    surface: Color(0xFF161E19),
    surfaceRaised: Color(0xFF1D2822),
    border: Color(0xFF26332B),
    textPrimary: Color(0xFFE7EEE9),
    textSecondary: Color(0xFF9CAAA2),
    primary: Color(0xFF34A873),
    primaryDark: Color(0xFF14573A),
    navBackground: Color(0xFF0A0F0C),
    income: Color(0xFF4CC38A),
    expense: Color(0xFFF0716A),
    heroCard: Color(0xFF14573A),
  );

  @override
  AppColorsT copyWith({
    Color? background, Color? surface, Color? surfaceRaised, Color? border,
    Color? textPrimary, Color? textSecondary, Color? primary, Color? primaryDark,
    Color? navBackground, Color? income, Color? expense, Color? heroCard,
  }) => AppColorsT(
    background: background ?? this.background, surface: surface ?? this.surface,
    surfaceRaised: surfaceRaised ?? this.surfaceRaised, border: border ?? this.border,
    textPrimary: textPrimary ?? this.textPrimary, textSecondary: textSecondary ?? this.textSecondary,
    primary: primary ?? this.primary, primaryDark: primaryDark ?? this.primaryDark,
    navBackground: navBackground ?? this.navBackground, income: income ?? this.income,
    expense: expense ?? this.expense, heroCard: heroCard ?? this.heroCard,
  );

  @override
  AppColorsT lerp(ThemeExtension<AppColorsT>? other, double t) {
    if (other is! AppColorsT) return this;
    return AppColorsT(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      heroCard: Color.lerp(heroCard, other.heroCard, t)!,
    );
  }

  static AppColorsT of(BuildContext context) => Theme.of(context).extension<AppColorsT>()!;
}

extension TextStyles on BuildContext {
  TextStyle get outfitBold => GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  TextStyle get outfitMedium => GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  TextStyle get interRegular => GoogleFonts.inter(color: AppColors.textPrimary);
  TextStyle get interMuted => GoogleFonts.inter(color: AppColors.textMuted);
  TextStyle get mono => GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600, color: AppColors.textPrimary);
}
