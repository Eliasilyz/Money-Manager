import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:money_manager/l10n/l10n_loader.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Manages notification channels and scheduling for the app.
///
/// ponytail: scheduling logic is stubbed — actual cron-like reschedule
/// lives in the backend/domain layer and should call into these methods
/// when data changes (new recurring, budget threshold hit, etc.).
class NotificationService {
  // Channel IDs
  static const kChannelRecurring = 'notif_recurring';
  static const kChannelDebt = 'notif_debt';
  static const kChannelBudget = 'notif_budget';
  static const kChannelDaily = 'notif_daily';
  static const kChannelBackup = 'notif_backup';

  // Notification IDs (base per channel)
  static const _idDaily = 1001;
  static const _idTest = 9999;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Pass [force] to rebuild channels after a locale change (Android keeps
  /// the first channel name/description unless the channel is re-created).
  Future<void> init({bool force = false}) async {
    if (_initialized && !force) return;
    tz_data.initializeTimeZones();

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      ),
    );

    // Channels are created implicitly on first notification per channel,
    // but we pre-create them for visibility in system settings.
    final l10n = await loadAppL10n();
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          kChannelRecurring,
          l10n.notificationTypeRecurring,
          description: l10n.notificationTypeRecurringDesc,
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          kChannelDebt,
          l10n.notificationTypeDebt,
          description: l10n.notificationTypeDebtDesc,
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          kChannelBudget,
          l10n.notificationTypeBudget,
          description: l10n.notificationTypeBudgetDesc,
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          kChannelDaily,
          l10n.notificationTypeDailyReminder,
          description: l10n.notificationTypeDailyReminderDesc,
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          kChannelBackup,
          l10n.notificationTypeBackupStatus,
          description: l10n.notificationTypeBackupStatusDesc,
          importance: Importance.high,
        ),
      );
    }
    _initialized = true;
  }

  /// Explicitly requests notification permission on Android 13+ and iOS.
  Future<bool> requestPermissions() async {
    await init();
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Schedules the daily transaction reminder at the given time (HH:mm).
  Future<void> scheduleDaily({String time = '19:00'}) async {
    await init();
    await requestPermissions();
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;

    final l10n = await loadAppL10n();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      _idDaily,
      l10n.financialSummary,
      l10n.notificationDailyBody,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          kChannelDaily,
          l10n.notificationTypeDailyReminder,
          channelDescription: l10n.notificationTypeDailyReminderDesc,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancels the scheduled daily reminder (keeps other channels intact).
  Future<void> cancelDaily() async {
    await _plugin.cancel(_idDaily);
  }

  // TODO: Implement scheduleRecurring() — iterate recurring txns, schedule
  // H-3/H-1/H-0 reminders using kChannelRecurring.
  Future<void> scheduleRecurring(List<dynamic> recurringItems) async {
    // Stub: each recurring item gets 3 reminders at dueDate-3, dueDate-1, dueDate.
  }

  // TODO: Implement scheduleDebtReminders() — iterate debts, schedule
  // H-3/H-1/H-0 reminders using kChannelDebt.
  Future<void> scheduleDebtReminders(List<dynamic> debts) async {
    // Stub: each debt gets 3 reminders at dueDate-3, dueDate-1, dueDate.
  }

  // TODO: Implement checkBudgetThreshold() — compare spent vs budget,
  // fire at 80% and 100% thresholds using kChannelBudget.
  Future<void> checkBudgetThreshold(dynamic budget) async {
    // Stub: fire notification when budget.spent >= budget.limit * 0.8 or 1.0.
  }

  // TODO: Implement checkBackupFailures() — fire kChannelBackup if
  // consecutive backup failures >= threshold.
  Future<void> checkBackupFailures(int consecutiveFailures) async {
    // Stub: fire notification when consecutiveFailures >= 3.
  }

  /// Sends a test notification on the daily channel.
  Future<void> sendTestNotification() async {
    await init();
    await requestPermissions();
    final l10n = await loadAppL10n();
    await _plugin.show(
      _idTest,
      l10n.notificationTestTitle,
      l10n.notificationTestBody,
      NotificationDetails(
        android: AndroidNotificationDetails(
          kChannelDaily,
          l10n.notificationTypeDailyReminder,
          channelDescription: l10n.notificationTypeDailyReminderDesc,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
