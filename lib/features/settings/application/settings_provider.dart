import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/core/constants/app_constants.dart';
import 'package:money_manager/features/settings/application/notification_service.dart';
import 'package:money_manager/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsServiceProvider = Provider((ref) => SettingsService());

class SettingsService {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';
  static const _pinKey = 'pin_hash';
  static const _saltKey = 'pin_salt';
  static const _biometricKey = 'biometric_enabled';
  static const _autoBackupKey = 'auto_backup';
  static const _wifiOnlyKey = 'wifi_only';
  static const _encryptKey = 'encrypt_backup';
  static const _notificationsKey = 'notifications_enabled';
  static const _notifRecurringKey = 'notif_recurring_enabled';
  static const _notifDebtKey = 'notif_debt_enabled';
  static const _notifBudgetKey = 'notif_budget_enabled';
  static const _notifDailyKey = 'notif_daily_enabled';
  static const _notifBackupKey = 'notif_backup_enabled';
  static const _notifDailyTimeKey = 'notif_daily_time';
  static const _baseCurrencyKey = 'base_currency';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<ThemeMode> getThemeMode() async {
    final prefs = await _prefs;
    final v = prefs.getString(_themeKey);
    if (v == 'light') return ThemeMode.light;
    if (v == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await _prefs;
    final s = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await prefs.setString(_themeKey, s);
  }

  Future<Locale> getLocale() async {
    final prefs = await _prefs;
    final code = prefs.getString(_localeKey);
    if (code == null) return const Locale('id');
    return Locale(code);
  }

  Future<void> saveLocale(Locale locale) async {
    final prefs = await _prefs;
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<String?> getPinHash() async => (await _prefs).getString(_pinKey);
  Future<String?> getPinSalt() async => (await _prefs).getString(_saltKey);
  Future<void> savePin(String hash, String salt) async {
    final prefs = await _prefs;
    await prefs.setString(_pinKey, hash);
    await prefs.setString(_saltKey, salt);
  }
  Future<void> clearPin() async {
    final prefs = await _prefs;
    await prefs.remove(_pinKey);
    await prefs.remove(_saltKey);
  }

  Future<bool> getBiometricEnabled() async => (await _prefs).getBool(_biometricKey) ?? false;
  Future<void> saveBiometricEnabled(bool v) async => (await _prefs).setBool(_biometricKey, v);
  Future<bool> getNotificationsEnabled() async => (await _prefs).getBool(_notificationsKey) ?? false;
  Future<void> saveNotificationsEnabled(bool v) async => (await _prefs).setBool(_notificationsKey, v);
  Future<bool> getAutoBackup() async => (await _prefs).getBool(_autoBackupKey) ?? false;
  Future<void> saveAutoBackup(bool v) async => (await _prefs).setBool(_autoBackupKey, v);
  Future<bool> getWifiOnly() async => (await _prefs).getBool(_wifiOnlyKey) ?? true;
  Future<void> saveWifiOnly(bool v) async => (await _prefs).setBool(_wifiOnlyKey, v);
  Future<bool> getEncryptBackup() async => (await _prefs).getBool(_encryptKey) ?? false;
  Future<void> saveEncryptBackup(bool v) async => (await _prefs).setBool(_encryptKey, v);

  // Per-type notification settings
  Future<bool> getNotifRecurring() async => (await _prefs).getBool(_notifRecurringKey) ?? true;
  Future<void> saveNotifRecurring(bool v) async => (await _prefs).setBool(_notifRecurringKey, v);
  Future<bool> getNotifDebt() async => (await _prefs).getBool(_notifDebtKey) ?? true;
  Future<void> saveNotifDebt(bool v) async => (await _prefs).setBool(_notifDebtKey, v);
  Future<bool> getNotifBudget() async => (await _prefs).getBool(_notifBudgetKey) ?? true;
  Future<void> saveNotifBudget(bool v) async => (await _prefs).setBool(_notifBudgetKey, v);
  Future<bool> getNotifDaily() async => (await _prefs).getBool(_notifDailyKey) ?? true;
  Future<void> saveNotifDaily(bool v) async => (await _prefs).setBool(_notifDailyKey, v);
  Future<bool> getNotifBackup() async => (await _prefs).getBool(_notifBackupKey) ?? true;
  Future<void> saveNotifBackup(bool v) async => (await _prefs).setBool(_notifBackupKey, v);
  Future<String> getNotifDailyTime() async => (await _prefs).getString(_notifDailyTimeKey) ?? '19:00';
  static const _themePresetKey = 'theme_preset';

  Future<AppThemePreset> getThemePreset() async {
    final prefs = await _prefs;
    final v = prefs.getString(_themePresetKey);
    return AppThemePreset.fromId(v);
  }

  Future<void> saveThemePreset(AppThemePreset preset) async {
    final prefs = await _prefs;
    await prefs.setString(_themePresetKey, preset.id);
  }

  Future<void> saveNotifDailyTime(String v) async => (await _prefs).setString(_notifDailyTimeKey, v);

  static const _backupIntervalKey = 'backup_interval';
  static const _maxBackupsKey = 'max_backups';

  Future<String> getBackupInterval() async => (await _prefs).getString(_backupIntervalKey) ?? 'Daily';
  Future<void> saveBackupInterval(String v) async => (await _prefs).setString(_backupIntervalKey, v);
  Future<int> getMaxBackups() async => (await _prefs).getInt(_maxBackupsKey) ?? 5;
  Future<void> saveMaxBackups(int v) async => (await _prefs).setInt(_maxBackupsKey, v);

  Future<String> getBaseCurrencyCode() async =>
      (await _prefs).getString(_baseCurrencyKey) ?? AppConstants.defaultBaseCurrency;
  Future<void> saveBaseCurrencyCode(String v) async => (await _prefs).setString(_baseCurrencyKey, v);
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final themePresetProvider = StateProvider<AppThemePreset>((ref) => AppThemePreset.emerald);
final localeProvider = StateProvider<Locale>((ref) => const Locale('id'));
final notificationsEnabledProvider = StateProvider<bool>((ref) => false);
final notifRecurringProvider = StateProvider<bool>((ref) => true);
final notifDebtProvider = StateProvider<bool>((ref) => true);
final notifBudgetProvider = StateProvider<bool>((ref) => true);
final notifDailyProvider = StateProvider<bool>((ref) => true);
final notifBackupProvider = StateProvider<bool>((ref) => true);
final notifDailyTimeProvider = StateProvider<String>((ref) => '19:00');
final baseCurrencyCodeProvider = StateProvider<String>((ref) => AppConstants.defaultBaseCurrency);

final autoBackupProvider = StateProvider<bool>((ref) => false);
final wifiOnlyProvider = StateProvider<bool>((ref) => true);
final backupIntervalProvider = StateProvider<String>((ref) => 'Daily');
final maxBackupsProvider = StateProvider<int>((ref) => 5);

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

final settingsInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(settingsServiceProvider);
  final tm = await service.getThemeMode();
  final preset = await service.getThemePreset();
  final loc = await service.getLocale();
  final notif = await service.getNotificationsEnabled();
  ref.read(themeModeProvider.notifier).state = tm;
  ref.read(themePresetProvider.notifier).state = preset;
  ref.read(localeProvider.notifier).state = loc;
  ref.read(notificationsEnabledProvider.notifier).state = notif;
  ref.read(notifRecurringProvider.notifier).state = await service.getNotifRecurring();
  ref.read(notifDebtProvider.notifier).state = await service.getNotifDebt();
  ref.read(notifBudgetProvider.notifier).state = await service.getNotifBudget();
  ref.read(notifDailyProvider.notifier).state = await service.getNotifDaily();
  ref.read(notifBackupProvider.notifier).state = await service.getNotifBackup();
  ref.read(notifDailyTimeProvider.notifier).state = await service.getNotifDailyTime();
  ref.read(baseCurrencyCodeProvider.notifier).state = await service.getBaseCurrencyCode();

  ref.read(autoBackupProvider.notifier).state = await service.getAutoBackup();
  ref.read(wifiOnlyProvider.notifier).state = await service.getWifiOnly();
  ref.read(backupIntervalProvider.notifier).state = await service.getBackupInterval();
  ref.read(maxBackupsProvider.notifier).state = await service.getMaxBackups();

  if (notif) {
    await ref.read(notificationServiceProvider).scheduleDaily();
  }
});