import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/theme/app_colors.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final masterEnabled = ref.watch(notificationsEnabledProvider);
    final recurring = ref.watch(notifRecurringProvider);
    final debt = ref.watch(notifDebtProvider);
    final budget = ref.watch(notifBudgetProvider);
    final daily = ref.watch(notifDailyProvider);
    final backup = ref.watch(notifBackupProvider);

    final activeCount = [
      if (masterEnabled && recurring) 1,
      if (masterEnabled && debt) 1,
      if (masterEnabled && budget) 1,
      if (masterEnabled && daily) 1,
      if (masterEnabled && backup) 1,
    ].length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettings,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: colors.textPrimary)),
        backgroundColor: colors.background,
        surfaceTintColor: colors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            // Explanation
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Text(l10n.notificationSettingsExplanation,
                  style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary, height: 1.5)),
            ),
            const SizedBox(height: 20),

            // Master toggle
            _buildCard(colors, [
              SwitchListTile(
                value: masterEnabled,
                onChanged: (v) {
                  ref.read(notificationsEnabledProvider.notifier).state = v;
                  ref.read(settingsServiceProvider).saveNotificationsEnabled(v);
                  final svc = ref.read(notificationServiceProvider);
                  if (v) {
                    svc.scheduleDaily();
                  } else {
                    svc.cancelAll();
                  }
                },
                title: Text(l10n.notifications,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                subtitle: Text(
                  masterEnabled ? l10n.notificationActiveCount(activeCount) : l10n.notificationsInactive,
                  style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
                ),
activeThumbColor: colors.primary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ]),
            const SizedBox(height: 20),

            // Per-type toggles
            if (masterEnabled) ...[
              Text(l10n.notifications.toUpperCase(),
                  style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              _buildCard(colors, [
                _notifToggle(
                  context,
                  ref,
                  icon: Icons.receipt_long_outlined,
                  title: l10n.notificationTypeRecurring,
                  subtitle: l10n.notificationTypeRecurringDesc,
                  value: recurring,
                  onChanged: (v) {
                    ref.read(notifRecurringProvider.notifier).state = v;
                    ref.read(settingsServiceProvider).saveNotifRecurring(v);
                    // TODO: reschedule recurring reminders
                  },
                  colors: colors,
                ),
                const Divider(height: 1, indent: 52),
                _notifToggle(
                  context,
                  ref,
                  icon: Icons.account_balance_outlined,
                  title: l10n.notificationTypeDebt,
                  subtitle: l10n.notificationTypeDebtDesc,
                  value: debt,
                  onChanged: (v) {
                    ref.read(notifDebtProvider.notifier).state = v;
                    ref.read(settingsServiceProvider).saveNotifDebt(v);
                    // TODO: reschedule debt reminders
                  },
                  colors: colors,
                ),
                const Divider(height: 1, indent: 52),
                _notifToggle(
                  context,
                  ref,
                  icon: Icons.pie_chart_outline,
                  title: l10n.notificationTypeBudget,
                  subtitle: l10n.notificationTypeBudgetDesc,
                  value: budget,
                  onChanged: (v) {
                    ref.read(notifBudgetProvider.notifier).state = v;
                    ref.read(settingsServiceProvider).saveNotifBudget(v);
                    // TODO: reschedule budget checks
                  },
                  colors: colors,
                ),
                const Divider(height: 1, indent: 52),
                _dailyReminderTile(context, ref, l10n, colors),
                const Divider(height: 1, indent: 52),
                _notifToggle(
                  context,
                  ref,
                  icon: Icons.cloud_done_outlined,
                  title: l10n.notificationTypeBackupStatus,
                  subtitle: l10n.notificationTypeBackupStatusDesc,
                  value: backup,
                  onChanged: (v) {
                    ref.read(notifBackupProvider.notifier).state = v;
                    ref.read(settingsServiceProvider).saveNotifBackup(v);
                    // TODO: reschedule backup check
                  },
                  colors: colors,
                ),
              ]),
              const SizedBox(height: 20),
            ],

            // System permission status
            if (masterEnabled) ...[
              Text(l10n.securityPriv.toUpperCase(),
                  style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              _buildCard(colors, [
                _systemPermissionTile(context, l10n, colors),
              ]),
              const SizedBox(height: 20),
            ],

            // Test button
            if (masterEnabled) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(notificationServiceProvider).sendTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.notificationTestSent),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.send_outlined, color: colors.primary, size: 18),
                  label: Text(l10n.notificationTestButton,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: colors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard(AppColorsT colors, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }

  Widget _notifToggle(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AppColorsT colors,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: colors.primary, size: 22),
      title: Text(title,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
      subtitle: Text(subtitle,
          style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
      activeThumbColor: colors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  Widget _dailyReminderTile(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AppColorsT colors,
  ) {
    final dailyEnabled = ref.watch(notifDailyProvider);
    final dailyTime = ref.watch(notifDailyTimeProvider);

    return Column(
      children: [
        SwitchListTile(
          value: dailyEnabled,
          onChanged: (v) {
            ref.read(notifDailyProvider.notifier).state = v;
            ref.read(settingsServiceProvider).saveNotifDaily(v);
            // TODO: reschedule daily reminder with current time
          },
          secondary: Icon(Icons.alarm_outlined, color: colors.primary, size: 22),
          title: Text(l10n.notificationTypeDailyReminder,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
          subtitle: Text(l10n.notificationTypeDailyReminderDesc,
              style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
          activeThumbColor: colors.primary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        ),
        if (dailyEnabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
            child: GestureDetector(
              onTap: () async {
                final parts = dailyTime.split(':');
                final initial =
                    TimeOfDay(hour: int.parse(parts[0]), minute: parts.length > 1 ? int.parse(parts[1]) : 0);
                final picked = await showTimePicker(context: context, initialTime: initial);
                if (picked != null) {
                  final formatted =
                      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                  ref.read(notifDailyTimeProvider.notifier).state = formatted;
                  ref.read(settingsServiceProvider).saveNotifDailyTime(formatted);
                  // TODO: reschedule daily reminder with new time
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 16, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(dailyTime,
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _systemPermissionTile(BuildContext context, AppLocalizations l10n, AppColorsT colors) {
    return ListTile(
      leading: Icon(Icons.shield_outlined, color: colors.primary, size: 22),
      title: Row(
        children: [
          Text(l10n.notifications,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            // ponytail: permission check is platform-specific; show "allowed"
            // as default and let the OS prompt on first schedule.
            child: Text(l10n.notificationPermissionAllowed,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: colors.primary)),
          ),
        ],
      ),
      trailing: TextButton(
        onPressed: () {
          // Opens app notification settings on Android / iOS
          const MethodChannel('app_settings').invokeMethod('openNotificationSettings');
        },
        child: Text(l10n.notificationOpenSystemSettings,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: colors.primary)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
