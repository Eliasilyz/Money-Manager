import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

export 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light({AppThemePreset preset = AppThemePreset.emerald}) {
    final colors = AppColorsT.forPreset(preset, isDark: false);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: <ThemeExtension<dynamic>>[colors],
      colorScheme: ColorScheme.light(surface: colors.surface, primary: colors.primary, error: colors.expense, onSurface: colors.textPrimary),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(backgroundColor: colors.primary, elevation: 0, titleTextStyle: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white), iconTheme: const IconThemeData(color: Colors.white), systemOverlayStyle: SystemUiOverlayStyle.light),
      cardTheme: CardThemeData(color: colors.surface, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colors.border))),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: colors.navBackground, elevation: 0, labelTextStyle: WidgetStateProperty.resolveWith((states) { if (states.contains(WidgetState.selected)) return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white); return GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)); }), iconTheme: WidgetStateProperty.resolveWith((states) { if (states.contains(WidgetState.selected)) return const IconThemeData(color: Colors.white, size: 24); return IconThemeData(color: Colors.white.withValues(alpha: 0.3), size: 24); })),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: colors.surface, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.primary, width: 1.5)), hintStyle: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14), labelStyle: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: colors.primary, foregroundColor: Colors.white, elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      snackBarTheme: SnackBarThemeData(backgroundColor: colors.surface, contentTextStyle: GoogleFonts.inter(color: colors.textPrimary, fontSize: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), behavior: SnackBarBehavior.floating),
      dialogTheme: DialogThemeData(backgroundColor: colors.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: colors.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))),
      tabBarTheme: TabBarThemeData(labelColor: Colors.white, unselectedLabelColor: Colors.white.withValues(alpha: 0.6), indicatorColor: Colors.white, labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14), unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14)),
      listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
    );
  }

  static ThemeData dark({AppThemePreset preset = AppThemePreset.emerald}) {
    final colors = AppColorsT.forPreset(preset, isDark: true);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: <ThemeExtension<dynamic>>[colors],
      colorScheme: ColorScheme.dark(surface: colors.surface, primary: colors.primary, error: colors.expense, onSurface: colors.textPrimary),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(backgroundColor: colors.heroCard, elevation: 0, titleTextStyle: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white), iconTheme: const IconThemeData(color: Colors.white), systemOverlayStyle: SystemUiOverlayStyle.light),
      cardTheme: CardThemeData(color: colors.surfaceRaised, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colors.border))),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: colors.navBackground, elevation: 0, labelTextStyle: WidgetStateProperty.resolveWith((states) { if (states.contains(WidgetState.selected)) return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white); return GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)); }), iconTheme: WidgetStateProperty.resolveWith((states) { if (states.contains(WidgetState.selected)) return const IconThemeData(color: Colors.white, size: 24); return IconThemeData(color: Colors.white.withValues(alpha: 0.2), size: 24); })),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: colors.surfaceRaised, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.primary, width: 1.5)), hintStyle: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14), labelStyle: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: colors.primary, foregroundColor: Colors.white, elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      snackBarTheme: SnackBarThemeData(backgroundColor: colors.surfaceRaised, contentTextStyle: GoogleFonts.inter(color: colors.textPrimary, fontSize: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), behavior: SnackBarBehavior.floating),
      dialogTheme: DialogThemeData(backgroundColor: colors.surfaceRaised, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: colors.surfaceRaised, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))),
      tabBarTheme: TabBarThemeData(labelColor: colors.primary, unselectedLabelColor: colors.textSecondary, indicatorColor: colors.primary, labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14), unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14)),
      listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
    );
  }
}
