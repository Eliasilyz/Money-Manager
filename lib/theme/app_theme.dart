import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

export 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    extensions: const <ThemeExtension<dynamic>>[AppColorsT.light],
    colorScheme: const ColorScheme.light(surface: Color(0xFFFFFFFF), primary: Color(0xFF1B6E4B), error: Color(0xFFE0524A), onSurface: Color(0xFF1A1F1C)),
    scaffoldBackgroundColor: const Color(0xFFF4F6F5),
    appBarTheme: AppBarTheme(backgroundColor: const Color(0xFF1B6E4B), elevation: 0, titleTextStyle: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white), iconTheme: const IconThemeData(color: Colors.white), systemOverlayStyle: SystemUiOverlayStyle.light),
    cardTheme: CardThemeData(color: const Color(0xFFFFFFFF), elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE6EBE8)))),
    navigationBarTheme: NavigationBarThemeData(backgroundColor: const Color(0xFF0E3B2B), elevation: 0, labelTextStyle: WidgetStateProperty.resolveWith((states) { if (states.contains(WidgetState.selected)) return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white); return GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)); }), iconTheme: WidgetStateProperty.resolveWith((states) { if (states.contains(WidgetState.selected)) return const IconThemeData(color: Colors.white, size: 24); return IconThemeData(color: Colors.white.withValues(alpha: 0.3), size: 24); })),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: const Color(0xFFFFFFFF), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE6EBE8))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE6EBE8))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1B6E4B), width: 1.5)), hintStyle: GoogleFonts.inter(color: const Color(0xFF7A857F), fontSize: 14), labelStyle: GoogleFonts.inter(color: const Color(0xFF7A857F), fontSize: 14)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: const Color(0xFF1B6E4B), foregroundColor: Colors.white, elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    snackBarTheme: SnackBarThemeData(backgroundColor: const Color(0xFFFFFFFF), contentTextStyle: GoogleFonts.inter(color: const Color(0xFF1A1F1C), fontSize: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), behavior: SnackBarBehavior.floating),
    dialogTheme: DialogThemeData(backgroundColor: const Color(0xFFFFFFFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Color(0xFFFFFFFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))),
    tabBarTheme: TabBarThemeData(labelColor: const Color(0xFF1B6E4B), unselectedLabelColor: const Color(0xFF7A857F), indicatorColor: const Color(0xFF1B6E4B), labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14), unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14)),
    listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    extensions: const <ThemeExtension<dynamic>>[AppColorsT.dark],
    colorScheme: const ColorScheme.dark(surface: Color(0xFF161E19), primary: Color(0xFF34A873), error: Color(0xFFF0716A), onSurface: Color(0xFFE7EEE9)),
    scaffoldBackgroundColor: const Color(0xFF0E1411),
    appBarTheme: AppBarTheme(backgroundColor: const Color(0xFF0E3B2B), elevation: 0, titleTextStyle: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white), iconTheme: const IconThemeData(color: Colors.white), systemOverlayStyle: SystemUiOverlayStyle.light),
    cardTheme: CardThemeData(color: const Color(0xFF1D2822), elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF26332B)))),
    navigationBarTheme: NavigationBarThemeData(backgroundColor: const Color(0xFF0A0F0C), elevation: 0, labelTextStyle: WidgetStateProperty.resolveWith((states) { if (states.contains(WidgetState.selected)) return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white); return GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)); }), iconTheme: WidgetStateProperty.resolveWith((states) { if (states.contains(WidgetState.selected)) return const IconThemeData(color: Colors.white, size: 24); return IconThemeData(color: Colors.white.withValues(alpha: 0.2), size: 24); })),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: const Color(0xFF1D2822), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF26332B))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF26332B))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF34A873), width: 1.5)), hintStyle: GoogleFonts.inter(color: const Color(0xFF9CAAA2), fontSize: 14), labelStyle: GoogleFonts.inter(color: const Color(0xFF9CAAA2), fontSize: 14)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: const Color(0xFF34A873), foregroundColor: Colors.white, elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    snackBarTheme: SnackBarThemeData(backgroundColor: const Color(0xFF1D2822), contentTextStyle: GoogleFonts.inter(color: const Color(0xFFE7EEE9), fontSize: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), behavior: SnackBarBehavior.floating),
    dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF1D2822), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Color(0xFF1D2822), shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))),
    tabBarTheme: TabBarThemeData(labelColor: const Color(0xFF34A873), unselectedLabelColor: const Color(0xFF9CAAA2), indicatorColor: const Color(0xFF34A873), labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14), unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14)),
    listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
  );
}
