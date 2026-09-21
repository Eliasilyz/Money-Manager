import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:package_info_plus/package_info_plus.dart';
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
            const SizedBox(height: 16),

            _buildProfileCard(context, colors),
            const SizedBox(height: 24),

            Text(l10n.financialManagement, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            _buildSectionCard(context, [
              _tile(context, Icons.category_outlined, l10n.categories, l10n.categoriesCount(categories.length), () => context.push('/categories')),
              const Divider(height: 1),
              _tile(context, Icons.repeat_rounded, l10n.recurring, l10n.activeRecurring(recurring.length), () => context.push('/recurring')),
              const Divider(height: 1),
              _tile(context, Icons.pie_chart_outline, '${l10n.budgets} & ${l10n.goalsAndDebts}', l10n.budgetsGoalsCount(budgets.length, goals.length), () => context.push('/budgets')),
              const Divider(height: 1),
              _tile(context, Icons.sticky_note_2_outlined, l10n.notes, '${categories.length} ${l10n.notes}', () => context.push('/notes')),
            ]),
            const SizedBox(height: 24),

            Text(l10n.preferences, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            _buildSectionCard(context, [
              _tile(context, Icons.cloud_sync_outlined, l10n.backupRestore, l10n.backupNow, () => context.push('/backup')),
              const Divider(height: 1),
              _tile(context, Icons.monetization_on_outlined, l10n.currency, 'Rupiah Indonesia (IDR)', () => context.push('/currencies')),
              const Divider(height: 1),
              _tile(context, Icons.notifications_none_outlined, l10n.notifications,
                  notif ? l10n.notificationActiveCount(activeNotifCount) : l10n.notificationsInactive,
                  () => context.push('/notification-settings')),
              const Divider(height: 1),
              _tile(context, Icons.palette_outlined, l10n.view, '$themeLabel • $langLabel', () => _showAppearanceDialog(context, ref)),
            ]),
            const SizedBox(height: 24),

            Text(l10n.aboutApp, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            _buildAboutHeader(context, colors, l10n),
            const SizedBox(height: 12),
            _buildAboutLinks(context, colors, l10n),
            if (AppLinks.showDonation) ...[
              const SizedBox(height: 12),
              _buildDonationCard(context, colors, l10n),
            ],
            const SizedBox(height: 12),
            _buildDebugInfoCard(context, colors, l10n),
            const SizedBox(height: 12),
            _buildChangelogCard(context, colors, l10n),
            const SizedBox(height: 12),
            _buildLicensesCard(context, colors, l10n),
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.view, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TEMA', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
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
            const SizedBox(height: 16),
            Text('BAHASA', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                _langOption(ctx, ref, l10n.indonesian, const Locale('id'), locale.languageCode == 'id'),
                const SizedBox(width: 8),
                _langOption(ctx, ref, l10n.english, const Locale('en'), locale.languageCode == 'en'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.close)),
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

  Widget _buildAboutHeader(BuildContext context, AppColorsT colors, AppLocalizations l10n) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final version = info?.version ?? '-';
        final buildNumber = info?.buildNumber ?? '-';
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              Text('Money Manager', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary)),
              const SizedBox(height: 4),
              Text(
                '${l10n.version} $version (${l10n.build} $buildNumber)',
                style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
              ),
              if (AppLinks.hasDeveloperCredits) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.developerCredits(AppLinks.developerName),
                  style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutLinks(BuildContext context, AppColorsT colors, AppLocalizations l10n) {
    final links = <_LinkItem>[];
    if (AppLinks.hasPrivacyPolicy) {
      links.add(_LinkItem(Icons.privacy_tip_outlined, l10n.privacyPolicy, AppLinks.privacyPolicyUrl));
    }
    if (AppLinks.hasTermsOfService) {
      links.add(_LinkItem(Icons.description_outlined, l10n.termsOfService, AppLinks.termsOfServiceUrl));
    }
    if (AppLinks.hasContactUrl) {
      links.add(_LinkItem(Icons.mail_outline, l10n.contact, AppLinks.contactUrl));
    }
    links.add(_LinkItem(Icons.star_outline, l10n.rateApp, AppLinks.rateAppUrl));

    if (links.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(context, [
      for (var i = 0; i < links.length; i++) ...[
        _aboutLinkTile(context, colors, links[i]),
        if (i < links.length - 1) const Divider(height: 1),
      ],
    ]);
  }

  Widget _aboutLinkTile(BuildContext context, AppColorsT colors, _LinkItem item) {
    return ListTile(
      onTap: () async {
        final uri = Uri.parse(item.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      leading: Icon(item.icon, color: colors.primary, size: 22),
      title: Text(item.label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
      trailing: Icon(Icons.chevron_right, color: colors.textSecondary, size: 18),
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

  Widget _buildDebugInfoCard(BuildContext context, AppColorsT colors, AppLocalizations l10n) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final version = info?.version ?? '-';
        final buildNumber = info?.buildNumber ?? '-';
        final os = Platform.operatingSystem;
        final locale = Platform.localeName;
        final debugText = 'v$version ($buildNumber)\nOS: $os\nLocale: $locale';

        return _buildSectionCard(context, [
          ListTile(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: debugText));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.copiedToClipboard), duration: const Duration(seconds: 1)),
              );
            },
            leading: Icon(Icons.info_outline, color: colors.primary, size: 22),
            title: Text(l10n.debugInfo, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
            subtitle: Text(l10n.copyInfo, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
          ),
        ]);
      },
    );
  }

  Widget _buildChangelogCard(BuildContext context, AppColorsT colors, AppLocalizations l10n) {
    return _buildSectionCard(context, [
      ListTile(
        leading: Icon(Icons.new_releases_outlined, color: colors.primary, size: 22),
        title: Text(l10n.changelog, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
        subtitle: Text(l10n.noChangelog, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
      ),
    ]);
  }

  Widget _buildLicensesCard(BuildContext context, AppColorsT colors, AppLocalizations l10n) {
    return _buildSectionCard(context, [
      ListTile(
        onTap: () => showLicensePage(context: context, applicationName: 'Money Manager'),
        leading: Icon(Icons.article_outlined, color: colors.primary, size: 22),
        title: Text(l10n.openSourceLicenses, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
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

class _LinkItem {
  final IconData icon;
  final String label;
  final String url;
  const _LinkItem(this.icon, this.label, this.url);
}
