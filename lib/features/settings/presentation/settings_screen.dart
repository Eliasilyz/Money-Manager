import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/core/config/app_links.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/features/recurring/application/recurring_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final notif = ref.watch(notificationsEnabledProvider);
    final notifRecurring = ref.watch(notifRecurringProvider);
    final notifDebt = ref.watch(notifDebtProvider);
    final notifBudget = ref.watch(notifBudgetProvider);
    final notifDaily = ref.watch(notifDailyProvider);
    final notifBackup = ref.watch(notifBackupProvider);
    final categories = ref.watch(categoriesNotifierProvider).valueOrNull ?? [];
    final budgets = ref.watch(budgetsNotifierProvider).valueOrNull ?? [];
    final goals = ref.watch(goalsNotifierProvider).valueOrNull ?? [];
    final recurring = ref.watch(recurringTransactionsNotifierProvider).valueOrNull ?? [];

    final activeNotifCount = [
      if (notif && notifRecurring) 1,
      if (notif && notifDebt) 1,
      if (notif && notifBudget) 1,
      if (notif && notifDaily) 1,
      if (notif && notifBackup) 1,
    ].length;

    final themeLabel = switch (themeMode) {
      ThemeMode.light => l10n.light,
      ThemeMode.dark => l10n.dark,
      _ => l10n.followSystem,
    };
    final langLabel = locale.languageCode == 'id' ? l10n.indonesian : l10n.english;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text(l10n.othersTitle, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            Text(l10n.appSettingsSubtitle, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
            const SizedBox(height: 16),

            _buildProfileCard(context, colors),
            const SizedBox(height: 24),

            Text(l10n.view, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            _buildSectionCard(context, [
              _tile(context, Icons.palette_outlined, l10n.theme, '$themeLabel • $langLabel', () => _showAppearanceDialog(context, ref)),
            ]),
            const SizedBox(height: 24),

            Text(l10n.otherFeatures, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            _buildSectionCard(context, [
              _tile(context, Icons.category_outlined, l10n.categories, l10n.categoriesCount(categories.length), () => context.push('/categories')),
              const Divider(height: 1),
              _tile(context, Icons.repeat_rounded, l10n.recurring, l10n.activeRecurring(recurring.length), () => context.push('/recurring')),
              const Divider(height: 1),
              _tile(context, Icons.pie_chart_outline, l10n.budgetsAndGoals, l10n.budgetsGoalsCount(budgets.length, goals.length), () => context.push('/budgets')),
              const Divider(height: 1),
              _tile(context, Icons.monetization_on_outlined, l10n.currency, l10n.defaultCurrencyName, () => context.push('/currencies')),
            ]),
            const SizedBox(height: 24),

            Text(l10n.dataAndSecurity, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            _buildSectionCard(context, [
              _tile(context, Icons.cloud_sync_outlined, l10n.backupRestore, l10n.backupNow, () => context.push('/backup')),
              const Divider(height: 1),
              _tile(context, Icons.security_outlined, l10n.securityPriv, l10n.securitySubtitle, () => context.push('/security')),
              const Divider(height: 1),
              _tile(context, Icons.notifications_none_outlined, l10n.notifications,
                  notif ? l10n.notificationActiveCount(activeNotifCount) : l10n.notificationsInactive,
                  () => context.push('/notification-settings')),
            ]),
            const SizedBox(height: 24),

            Text(l10n.helpAndInfo, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            _buildSectionCard(context, [
              _tile(context, Icons.info_outline, l10n.aboutApp, 'Money Manager • ${l10n.version}', () {}),
            ]),
            if (AppLinks.showDonation) ...[
              const SizedBox(height: 12),
              _buildDonationCard(context, colors, l10n),
            ],
            const SizedBox(height: 16),
            _buildCopyrightFooter(colors, l10n),
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
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.read(themeModeProvider);
    final locale = ref.read(localeProvider);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.view, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Text(l10n.themeUppercase, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                _themeOption(ctx, ref, l10n.light, ThemeMode.light, themeMode == ThemeMode.light),
                const SizedBox(width: 8),
                _themeOption(ctx, ref, l10n.dark, ThemeMode.dark, themeMode == ThemeMode.dark),
                const SizedBox(width: 8),
                _themeOption(ctx, ref, l10n.followSystem, ThemeMode.system, themeMode == ThemeMode.system),
              ],
            ),
            const SizedBox(height: 20),
            Text(l10n.languageUppercase, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                _langOption(ctx, ref, l10n.indonesian, const Locale('id'), locale.languageCode == 'id'),
                const SizedBox(width: 8),
                _langOption(ctx, ref, l10n.english, const Locale('en'), locale.languageCode == 'en'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.bg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(l10n.close, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
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

  Widget _buildDonationCard(BuildContext context, AppColorsT colors, AppLocalizations l10n) {
    return _buildSectionCard(context, [
      ListTile(
        onTap: () async {
          final uri = Uri.parse(AppLinks.donationUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        leading: Icon(Icons.favorite_outline, color: colors.expense, size: 22),
        title: Text(l10n.donation, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
        trailing: Icon(Icons.chevron_right, color: colors.textSecondary, size: 18),
      ),
    ]);
  }

  Widget _buildCopyrightFooter(AppColorsT colors, AppLocalizations l10n) {
    return Center(
      child: Text(
        '${l10n.madeWith} ${String.fromCharCode(0x2764)} ${l10n.allRightsReserved(DateTime.now().year)}',
        style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }
}
