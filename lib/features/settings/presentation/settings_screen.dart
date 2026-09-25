import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/core/config/app_links.dart';
import 'package:money_manager/core/constants/app_constants.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/features/recurring/application/recurring_provider.dart';
import 'package:money_manager/features/settings/application/auth_service.dart';
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
    final baseCode = ref.watch(baseCurrencyCodeProvider);

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

            _buildProfileCard(context, colors, l10n, ref),
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
              _tile(context, Icons.monetization_on_outlined, l10n.currency, '${l10n.baseCurrency}: $baseCode', () => context.push('/currencies')),
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
              _tile(context, Icons.info_outline, l10n.aboutApp, 'Money Manager • v${AppConstants.appVersion}', () => _showAboutBottomSheet(context, colors, l10n)),
              if (AppLinks.hasContactUrl) ...[
                const Divider(height: 1),
                _tile(context, Icons.mail_outline, l10n.contact, AppLinks.contactUrl.replaceFirst('mailto:', ''), () => _openExternalUrl(AppLinks.contactUrl)),
              ],
              if (AppLinks.hasPrivacyPolicy) ...[
                const Divider(height: 1),
                _tile(context, Icons.privacy_tip_outlined, l10n.privacyPolicy, l10n.privacyPolicy, () => _openExternalUrl(AppLinks.privacyPolicyUrl)),
              ],
              if (AppLinks.hasTermsOfService) ...[
                const Divider(height: 1),
                _tile(context, Icons.description_outlined, l10n.termsOfService, l10n.termsOfService, () => _openExternalUrl(AppLinks.termsOfServiceUrl)),
              ],
              if (AppLinks.hasRateApp) ...[
                const Divider(height: 1),
                _tile(context, Icons.star_outline, l10n.rateApp, l10n.rateApp, () => _openExternalUrl(AppLinks.rateAppUrl)),
              ],
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

  Widget _buildProfileCard(BuildContext context, AppColorsT colors, AppLocalizations l10n, WidgetRef ref) {
    final user = ref.watch(googleUserNotifierProvider);
    return GestureDetector(
      onTap: () => context.push('/backup'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            if (user?.photoUrl != null)
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(user!.photoUrl!),
              )
            else
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primary,
                child: Text(
                  user != null
                      ? (user.displayName ?? user.email).substring(0, 1).toUpperCase()
                      : 'ME',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16),
                ),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user != null ? (user.displayName ?? 'Google User') : l10n.profileName,
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_done, size: 10, color: AppColors.gold),
                              const SizedBox(width: 3),
                              Text(
                                'GDrive',
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: colors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    user != null ? user.email : l10n.notSignedIn,
                    style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
                  ),
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
        onTap: () async {
          ref.read(localeProvider.notifier).state = loc;
          await ref.read(settingsServiceProvider).saveLocale(loc);
          // Rebuild notification channels + reschedule so their text follows the new locale.
          if (ref.read(notificationsEnabledProvider)) {
            final svc = ref.read(notificationServiceProvider);
            await svc.init(force: true);
            if (ref.read(notifDailyProvider)) {
              await svc.scheduleDaily(time: ref.read(notifDailyTimeProvider));
            }
          }
          if (ctx.mounted) Navigator.pop(ctx);
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

  Future<void> _openExternalUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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

  void _showAboutBottomSheet(BuildContext context, AppColorsT colors, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: ClipOval(
                  child: Image.asset('assets/icons/app_icon.png', fit: BoxFit.cover, width: 64, height: 64),
                ),
              ),
              const SizedBox(height: 14),
              Text('Money Manager', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: colors.textPrimary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(l10n.aboutVersion('1', AppConstants.appVersion), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.aboutDesc,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              Divider(color: colors.border),
              const SizedBox(height: 12),
              if (AppLinks.hasDeveloperCredits) ...[
                _aboutInfoRow(l10n.developer, AppLinks.developerName, Icons.person_outline, colors),
                const SizedBox(height: 10),
              ],
              _aboutInfoRow(l10n.license, 'GNU AGPLv3 • Open Source', Icons.verified_user_outlined, colors),
              const SizedBox(height: 16),
              if (AppLinks.showDonation) ...[
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final uri = Uri.parse(AppLinks.donationUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.expense,
                      side: BorderSide(color: colors.expense),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.favorite, size: 18),
                    label: Text(l10n.supportDeveloper, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.close, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aboutInfoRow(String label, String value, IconData icon, AppColorsT colors) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary)),
        const Spacer(),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
      ],
    );
  }
}
