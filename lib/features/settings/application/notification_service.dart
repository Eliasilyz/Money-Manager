import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  Future<void> init() async {
    tz_data.initializeTimeZones();

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    // Channels are created implicitly on first notification per channel,
    // but we pre-create them for visibility in system settings.
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(kChannelRecurring, 'Tagihan & Transaksi Berulang',
            description: 'Pengingat H-0, H-1, H-3 untuk tagihan dan transaksi berulang',
            importance: Importance.high),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(kChannelDebt, 'Hutang & Cicilan',
            description: 'Pengingat H-0, H-1, H-3 untuk jatuh tempo hutang dan cicilan',
            importance: Importance.high),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(kChannelBudget, 'Peringatan Anggaran',
            description: 'Notifikasi saat anggaran mencapai 80% dan 100%',
            importance: Importance.high),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(kChannelDaily, 'Pengingat Harian',
            description: 'Pengingat catat transaksi harian',
            importance: Importance.defaultImportance),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(kChannelBackup, 'Status Backup',
            description: 'Notifikasi jika backup gagal beberapa kali berturut-turut',
            importance: Importance.high),
      );
    }
  }

  /// Schedules the daily transaction reminder at the given time (HH:mm).
  Future<void> scheduleDaily({String time = '19:00'}) async {
    await init();
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      _idDaily,
      'Ringkasan keuangan',
      'Jangan lupa catat pengeluaran hari ini',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          kChannelDaily,
          'Pengingat Harian',
          channelDescription: 'Pengingat catat transaksi harian',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
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
    await _plugin.show(
      _idTest,
      'Notifikasi tes',
      'Jika kamu melihat ini, notifikasi berfungsi!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          kChannelDaily,
          'Pengingat Harian',
          channelDescription: 'Pengingat catat transaksi harian',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
