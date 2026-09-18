import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Backgrounds — deep navy-ink
  static const bg = Color(0xFF070B18);
  static const surface = Color(0xFF0B1022);
  static const card = Color(0xFF0F1630);
  static const card2 = Color(0xFF141D3A);

  // Primary — warm gold
  static const gold = Color(0xFFF4C430);
  static const gold2 = Color(0xFFE8A800);

  // Semantic
  static const teal = Color(0xFF22D4A6);   // income / positive
  static const rose = Color(0xFFFF4757);   // expense / negative
  static const sky = Color(0xFF5E9BFF);    // transfer / info
  static const orange = Color(0xFFFF9F43); // warning
  static const lilac = Color(0xFFA78BFA);  // goals / accent

  // Text
  static const textPrimary = Color(0xFFEEF0FB);
  static const textMuted = Color(0x6BEEF0FB);
  static const textDim = Color(0x38EEF0FB);

  // Borders
  static const border = Color(0x12FFFFFF);

  // Deprecated aliases
  static const textDisabled = textDim;
  static const emerald = teal;
  static const coral = rose;
  static const violet = lilac;
  static const blue = sky;
  static const amber = orange;
}

class AppTheme {
  AppTheme._();

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.gold,
      secondary: AppColors.lilac,
      error: AppColors.rose,
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
      indicatorColor: AppColors.gold.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold);
        }
        return GoogleFonts.inter(fontSize: 12, color: AppColors.textDim);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.gold, size: 24);
        }
        return const IconThemeData(color: AppColors.textDim, size: 24);
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
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(color: AppColors.textDim, fontSize: 14),
      labelStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.gold,
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
      labelColor: AppColors.gold,
      unselectedLabelColor: AppColors.textDim,
      indicatorColor: AppColors.gold,
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.card,
      selectedColor: AppColors.gold,
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
      color: AppColors.gold,
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
