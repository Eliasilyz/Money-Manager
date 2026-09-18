import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const bg = Color(0xFF0A0A0F);
  static const surface = Color(0xFF12121A);
  static const card = Color(0xFF1A1A26);
  static const card2 = Color(0xFF1F1F2E);

  static const emerald = Color(0xFF00E096);
  static const coral = Color(0xFFFF5252);
  static const amber = Color(0xFFFFB800);
  static const violet = Color(0xFF8B5CF6);
  static const blue = Color(0xFF3B82F6);

  static const textPrimary = Color(0xFFF0F0F8);
  static const textMuted = Color(0x73FFFFFF);
  static const textDisabled = Color(0x40FFFFFF);

  static const border = Color(0x14FFFFFF);
  static const borderMid = Color(0x1AFFFFFF);
}

class AppTheme {
  AppTheme._();

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.emerald,
      secondary: AppColors.violet,
      error: AppColors.coral,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textMuted),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      indicatorColor: AppColors.emerald.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.emerald);
        }
        return GoogleFonts.inter(fontSize: 12, color: AppColors.textDisabled);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.emerald, size: 24);
        }
        return const IconThemeData(color: AppColors.textDisabled, size: 24);
      }),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(color: AppColors.textDisabled, fontSize: 14),
      labelStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.emerald,
      foregroundColor: AppColors.bg,
      elevation: 4,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.card2,
      contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.emerald,
      unselectedLabelColor: AppColors.textDisabled,
      indicatorColor: AppColors.emerald,
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.card,
      selectedColor: AppColors.emerald,
      labelStyle: GoogleFonts.inter(fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.emerald,
      linearTrackColor: AppColors.border,
    ),
  );
}

extension TextStyles on BuildContext {
  TextStyle get outfitBold => GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  TextStyle get outfitMedium => GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  TextStyle get interRegular => GoogleFonts.inter(color: AppColors.textPrimary);
  TextStyle get interMuted => GoogleFonts.inter(color: AppColors.textMuted);
  TextStyle get mono => GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600, color: AppColors.textPrimary);
}

