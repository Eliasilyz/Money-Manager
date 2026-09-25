import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const bg = Color(0xFFF4F6F5);
  static const surface = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const card2 = Color(0xFFF4F6F5);
  static const gold = Color(0xFF1B6E4B);
  static const gold2 = Color(0xFF0F5A3C);
  static const teal = Color(0xFF22D4A6);
  static const rose = Color(0xFFFF4757);
  static const sky = Color(0xFF5E9BFF);
  static const orange = Color(0xFFFF9F43);
  static const lilac = Color(0xFFA78BFA);
  static const textPrimary = Color(0xFF1A1F1C);
  static const textMuted = Color(0xFF7A857F);
  static const textDim = Color(0xFFB0B8B3);
  static const border = Color(0xFFE6EBE8);
  static const emerald = teal;
  static const coral = rose;
  static const violet = lilac;
  static const blue = sky;
  static const amber = orange;
}

enum AppThemePreset {
  emerald(
    id: 'emerald',
    name: 'Emerald Forest',
    primaryLight: Color(0xFF1B6E4B),
    primaryDarkLight: Color(0xFF0F5A3C),
    navBgLight: Color(0xFF0E3B2B),
    heroLight: Color(0xFF0F5A3C),
    primaryDarkTheme: Color(0xFF34A873),
    primaryDarkDark: Color(0xFF14573A),
    navBgDark: Color(0xFF0A0F0C),
    heroDark: Color(0xFF14573A),
    previewColor: Color(0xFF1B6E4B),
  ),
  ocean(
    id: 'ocean',
    name: 'Ocean Sapphire',
    primaryLight: Color(0xFF1A5694),
    primaryDarkLight: Color(0xFF0E3864),
    navBgLight: Color(0xFF0C2B4E),
    heroLight: Color(0xFF0E3864),
    primaryDarkTheme: Color(0xFF4C93DC),
    primaryDarkDark: Color(0xFF154374),
    navBgDark: Color(0xFF091624),
    heroDark: Color(0xFF154374),
    previewColor: Color(0xFF1A5694),
  ),
  midnight(
    id: 'midnight',
    name: 'Midnight Dark',
    primaryLight: Color(0xFF263238),
    primaryDarkLight: Color(0xFF192227),
    navBgLight: Color(0xFF10171B),
    heroLight: Color(0xFF192227),
    primaryDarkTheme: Color(0xFF38BDF8),
    primaryDarkDark: Color(0xFF0369A1),
    navBgDark: Color(0xFF0B0F12),
    heroDark: Color(0xFF0C2434),
    previewColor: Color(0xFF38BDF8),
  ),
  sunset(
    id: 'sunset',
    name: 'Sunset Terracotta',
    primaryLight: Color(0xFFB45309),
    primaryDarkLight: Color(0xFF78350F),
    navBgLight: Color(0xFF451A03),
    heroLight: Color(0xFF78350F),
    primaryDarkTheme: Color(0xFFF59E0B),
    primaryDarkDark: Color(0xFF92400E),
    navBgDark: Color(0xFF1C0E05),
    heroDark: Color(0xFF451A03),
    previewColor: Color(0xFFB45309),
  ),
  amethyst(
    id: 'amethyst',
    name: 'Royal Amethyst',
    primaryLight: Color(0xFF6D28D9),
    primaryDarkLight: Color(0xFF4C1D95),
    navBgLight: Color(0xFF2E1065),
    heroLight: Color(0xFF4C1D95),
    primaryDarkTheme: Color(0xFFA78BFA),
    primaryDarkDark: Color(0xFF5B21B6),
    navBgDark: Color(0xFF130924),
    heroDark: Color(0xFF2E1065),
    previewColor: Color(0xFF6D28D9),
  );

  final String id;
  final String name;
  final Color primaryLight;
  final Color primaryDarkLight;
  final Color navBgLight;
  final Color heroLight;
  final Color primaryDarkTheme;
  final Color primaryDarkDark;
  final Color navBgDark;
  final Color heroDark;
  final Color previewColor;

  const AppThemePreset({
    required this.id,
    required this.name,
    required this.primaryLight,
    required this.primaryDarkLight,
    required this.navBgLight,
    required this.heroLight,
    required this.primaryDarkTheme,
    required this.primaryDarkDark,
    required this.navBgDark,
    required this.heroDark,
    required this.previewColor,
  });

  static AppThemePreset fromId(String? id) {
    return AppThemePreset.values.firstWhere(
      (p) => p.id == id,
      orElse: () => AppThemePreset.emerald,
    );
  }
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

  static AppColorsT forPreset(AppThemePreset preset, {required bool isDark}) {
    if (isDark) {
      return AppColorsT(
        background: const Color(0xFF0E1411),
        surface: const Color(0xFF161E19),
        surfaceRaised: const Color(0xFF1D2822),
        border: const Color(0xFF26332B),
        textPrimary: const Color(0xFFE7EEE9),
        textSecondary: const Color(0xFF9CAAA2),
        primary: preset.primaryDarkTheme,
        primaryDark: preset.primaryDarkDark,
        navBackground: preset.navBgDark,
        income: const Color(0xFF4CC38A),
        expense: const Color(0xFFF0716A),
        heroCard: preset.heroDark,
      );
    } else {
      return AppColorsT(
        background: const Color(0xFFF4F6F5),
        surface: const Color(0xFFFFFFFF),
        surfaceRaised: const Color(0xFFFFFFFF),
        border: const Color(0xFFE6EBE8),
        textPrimary: const Color(0xFF1A1F1C),
        textSecondary: const Color(0xFF7A857F),
        primary: preset.primaryLight,
        primaryDark: preset.primaryDarkLight,
        navBackground: preset.navBgLight,
        income: const Color(0xFF1F7A4D),
        expense: const Color(0xFFE0524A),
        heroCard: preset.heroLight,
      );
    }
  }

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

  Color get heroCardBg => heroCard;
  Color get cardBackground => surface;
  Color get card => surface;
  Color get card2 => surfaceRaised;
  Color get textMuted => textSecondary;
  Color get gold => primary;
  Color get gold2 => primaryDark;

  static AppColorsT of(BuildContext context) => Theme.of(context).extension<AppColorsT>()!;
}

extension TextStyles on BuildContext {
  TextStyle get outfitBold => GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColorsT.of(this).textPrimary);
  TextStyle get outfitMedium => GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppColorsT.of(this).textPrimary);
  TextStyle get interRegular => GoogleFonts.inter(color: AppColorsT.of(this).textPrimary);
  TextStyle get interMuted => GoogleFonts.inter(color: AppColorsT.of(this).textSecondary);
  TextStyle get mono => GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600, color: AppColorsT.of(this).textPrimary);
}
