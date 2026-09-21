import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/features/recurring/application/recurring_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final notif = ref.watch(notificationsEnabledProvider);
    final categories = ref.watch(categoriesNotifierProvider).valueOrNull ?? [];
    final budgets = ref.watch(budgetsNotifierProvider).valueOrNull ?? [];
    final goals = ref.watch(goalsNotifierProvider).valueOrNull ?? [];
    final recurring = ref.watch(recurringTransactionsNotifierProvider).valueOrNull ?? [];

    final themeLabel = switch (themeMode) {
      ThemeMode.light => 'Tema terang',
      ThemeMode.dark => 'Tema gelap',
      _ => 'Ikuti sistem',
    };
    final langLabel = locale.languageCode == 'id' ? 'Indonesia' : 'English';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text('Lainnya', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            const SizedBox(height: 16),

            _buildProfileCard(context, colors),
            const SizedBox(height: 24),

            Text('Kelola keuangan', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            _buildSectionCard(context, [
              _tile(context, Icons.category_outlined, 'Kategori', '${categories.length} kategori', () => context.push('/categories')),
              const Divider(height: 1),
              _tile(context, Icons.repeat_rounded, 'Transaksi Berulang', '${recurring.length} transaksi aktif', () => context.push('/recurring')),
              const Divider(height: 1),
              _tile(context, Icons.pie_chart_outline, 'Anggaran & Target', '${budgets.length} anggaran • ${goals.length} target', () => context.push('/budgets')),
              const Divider(height: 1),
              _tile(context, Icons.sticky_note_2_outlined, 'Catatan', 'Catatan pribadi', () => context.push('/notes')),
            ]),
            const SizedBox(height: 24),

            Text('Preferensi', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            _buildSectionCard(context, [
              _tile(context, Icons.cloud_sync_outlined, 'Backup & Restore', 'Cadangkan & pulihkan data', () => context.push('/backup')),
              const Divider(height: 1),
              _tile(context, Icons.monetization_on_outlined, 'Mata Uang', 'Rupiah Indonesia (IDR)', () => context.push('/currencies')),
              const Divider(height: 1),
              _tile(context, Icons.notifications_none_outlined, 'Notifikasi', notif ? 'Pengingat aktif' : 'Pengingat nonaktif', () {
                final n = !notif;
                ref.read(notificationsEnabledProvider.notifier).state = n;
                ref.read(settingsServiceProvider).saveNotificationsEnabled(n);
                final svc = ref.read(notificationServiceProvider);
                if (n) {
                  svc.scheduleDaily();
                } else {
                  svc.cancelAll();
                }
              }),
              const Divider(height: 1),
              _tile(context, Icons.palette_outlined, 'Tampilan', '$themeLabel • $langLabel', () => _showAppearanceDialog(context, ref)),
            ]),
            const SizedBox(height: 24),

            Text('Tentang aplikasi', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            _buildSectionCard(context, [
              _tile(context, Icons.info_outline, 'Tentang Money Manager', 'Versi 1.0.0 (Build 1)', () => _showAboutDialog(context)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AppColorsT colors) {
    return GestureDetector(
      onTap: () => context.push('/security'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colors.primary,
              child: Text('ME', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mas Elon', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                  Text('maselon@email.com', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, List<Widget> children) {
    final colors = AppColorsT.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    final colors = AppColorsT.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: colors.primary, size: 22),
      title: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
      trailing: Icon(Icons.chevron_right, color: colors.textSecondary, size: 18),
    );
  }

  void _showAppearanceDialog(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final themeMode = ref.read(themeModeProvider);
    final locale = ref.read(localeProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tampilan', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TEMA', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                _themeOption(ctx, ref, 'Terang', ThemeMode.light, themeMode == ThemeMode.light),
                const SizedBox(width: 8),
                _themeOption(ctx, ref, 'Gelap', ThemeMode.dark, themeMode == ThemeMode.dark),
                const SizedBox(width: 8),
                _themeOption(ctx, ref, 'Sistem', ThemeMode.system, themeMode == ThemeMode.system),
              ],
            ),
            const SizedBox(height: 16),
            Text('BAHASA', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                _langOption(ctx, ref, 'Indonesia', const Locale('id'), locale.languageCode == 'id'),
                const SizedBox(width: 8),
                _langOption(ctx, ref, 'English', const Locale('en'), locale.languageCode == 'en'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Widget _themeOption(BuildContext ctx, WidgetRef ref, String label, ThemeMode mode, bool selected) {
    final colors = AppColorsT.of(ctx);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(themeModeProvider.notifier).state = mode;
          ref.read(settingsServiceProvider).saveThemeMode(mode);
          Navigator.pop(ctx);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.surfaceRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? colors.primary : colors.border),
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.textPrimary)),
          ),
        ),
      ),
    );
  }

  Widget _langOption(BuildContext ctx, WidgetRef ref, String label, Locale loc, bool selected) {
    final colors = AppColorsT.of(ctx);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(localeProvider.notifier).state = loc;
          ref.read(settingsServiceProvider).saveLocale(loc);
          Navigator.pop(ctx);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.surfaceRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? colors.primary : colors.border),
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.textPrimary)),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Money Manager',
      applicationVersion: '1.0.0 (Build 1)',
      applicationLegalese: '© 2026 Money Manager. Hak cipta dilindungi.',
    );
  }
}
