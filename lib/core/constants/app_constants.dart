class AppConstants {
  static const int databaseSchemaVersion = 4;
  static const String defaultBaseCurrency = 'IDR';
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const int defaultCurrencyDecimalDigits = 0;
  static const double defaultExchangeRate = 1.0;
  static const int backupSchemaVersion = 1;
  static const String appVersion = '1.0.0';
  static const String databaseFileName = 'money_manager.db';
  static const String backupFileName = 'money-manager-backup-v1.json';
  static const int maxBackupFileSizeBytes = 50 * 1024 * 1024;
  static const String googleDriveAppFolder = 'app_data';
  static const Duration autoBackupInterval = Duration(hours: 24);
  static const String encryptionKeyAlias = 'money_manager_encryption_key';
  static const int paginationPageSize = 50;
  static const int defaultMaxBackups = 5;

  AppConstants._();
}
