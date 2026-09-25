import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:money_manager/core/constants/app_constants.dart';
import 'package:money_manager/core/crypto/crypto_utils.dart';
import 'package:money_manager/database/database.dart' as db;
import 'package:money_manager/features/settings/application/auth_service.dart';
import 'package:money_manager/features/settings/application/google_drive_service.dart';
import 'package:money_manager/l10n/l10n_loader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const backupFormatIdentifier = 'money_manager_backup';
const backupEncryptionMarker = 'encrypted_backup';

class BackupException implements Exception {
  final String message;
  const BackupException(this.message);
  @override
  String toString() => message;
}

class BackupService {
  const BackupService();

  static const String _keyLastBackupTime = 'backup_last_time';
  static const String _keyLastBackupHash = 'backup_last_hash';
  static const String _keyLastBackupFailure = 'backup_last_failure';

  // --- Backup generation ---

  Future<String> generateBackup(db.AppDatabase database, {String? password}) async {
    final data = await _collectAll(database);
    final bundle = const JsonEncoder.withIndent('  ').convert({
      'format': backupFormatIdentifier,
      'schemaVersion': AppConstants.backupSchemaVersion,
      'appVersion': AppConstants.appVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'data': data,
    });
    if (password == null || password.isEmpty) return bundle;
    return jsonEncode({
      'format': backupEncryptionMarker,
      'payload': CryptoUtils.encryptData(bundle, password),
    });
  }

  /// Creates a gzipped backup and returns the raw bytes.
  Future<List<int>> createCompressedBackup(db.AppDatabase database, {String? password}) async {
    final json = await generateBackup(database, password: password);
    return gzip.encode(utf8.encode(json));
  }

  /// Computes a hash of the current database state. Returns true if the hash
  /// matches the last recorded hash (i.e. no changes since last backup).
  Future<bool> shouldSkipBackup(db.AppDatabase database) async {
    final data = await _collectAll(database);
    final canonical = const JsonEncoder().convert(data);
    final hash = md5.convert(utf8.encode(canonical)).toString();
    final lastHash = await _readLastHash();
    return hash == lastHash;
  }

  Future<String> getDatabaseDataHash(db.AppDatabase database) async {
    final data = await _collectAll(database);
    final canonical = const JsonEncoder().convert(data);
    return md5.convert(utf8.encode(canonical)).toString();
  }

  Future<void> recordBackupSuccess([String? dataHash]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastBackupTime, DateTime.now().toIso8601String());
    if (dataHash != null) {
      await prefs.setString(_keyLastBackupHash, dataHash);
    }
    await prefs.remove(_keyLastBackupFailure);
  }

  Future<void> recordBackupFailure(String reason) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastBackupFailure, '$reason (${DateFormat('dd MMM, HH:mm').format(DateTime.now())})');
  }

  Future<DateTime?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_keyLastBackupTime);
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }

  Future<String?> getLastBackupFailure() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastBackupFailure);
  }

  Future<String?> _readLastHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastBackupHash);
  }

  // --- Google Drive Integration ---

  Future<DriveBackupFile> performBackupToDrive({
    required db.AppDatabase database,
    required AuthService authService,
    required GoogleDriveService driveService,
    String? password,
    bool isAutoBackup = false,
    int maxBackups = 5,
  }) async {
    final authHeaders = await authService.getAuthHeaders();
    if (authHeaders == null) {
      throw BackupException((await loadAppL10n()).backupSignInRequired);
    }

    final bytes = await createCompressedBackup(database, password: password);
    final dataHash = await getDatabaseDataHash(database);

    final timestampStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final prefix = isAutoBackup ? 'money_manager_backup_auto' : 'money_manager_backup';
    final fileName = '${prefix}_$timestampStr.json.gz';

    final backupFile = await driveService.uploadBackup(
      authHeaders: authHeaders,
      bytes: bytes,
      fileName: fileName,
      isAutoBackup: isAutoBackup,
    );

    await recordBackupSuccess(dataHash);

    // Auto trim old backups if needed
    if (isAutoBackup) {
      await driveService.trimOldAutoBackups(authHeaders: authHeaders, maxKeep: maxBackups);
    }

    return backupFile;
  }

  Future<int> restoreFromDrive({
    required db.AppDatabase database,
    required AuthService authService,
    required GoogleDriveService driveService,
    required String fileId,
    String? password,
  }) async {
    final authHeaders = await authService.getAuthHeaders();
    if (authHeaders == null) {
      throw BackupException((await loadAppL10n()).backupSignInRequired);
    }

    final bytes = await driveService.downloadBackup(authHeaders: authHeaders, fileId: fileId);

    String jsonStr;
    try {
      jsonStr = utf8.decode(gzip.decode(bytes));
    } catch (_) {
      try {
        jsonStr = utf8.decode(bytes);
      } catch (_) {
        throw BackupException((await loadAppL10n()).backupDriveFileUnreadable);
      }
    }

    final parsedData = await parseBackup(jsonStr, password: password);

    // Create safety snapshot before overwriting
    await createSafetySnapshot(database);

    try {
      final restoredCount = await restoreBackup(database, parsedData);
      await deleteSafetySnapshot();
      return restoredCount;
    } catch (e) {
      await rollbackFromSafetySnapshot(database);
      rethrow;
    }
  }

  Future<String> getDriveBackupSizeFormatted({
    required AuthService authService,
    required GoogleDriveService driveService,
  }) async {
    try {
      final authHeaders = await authService.getAuthHeaders();
      if (authHeaders == null) return '0 B';
      final totalBytes = await driveService.getTotalBackupBytes(authHeaders);
      return formatBytes(totalBytes);
    } catch (_) {

      return '0 B';
    }
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double d = bytes.toDouble();
    while (d >= 1024 && i < suffixes.length - 1) {
      d /= 1024;
      i++;
    }
    return '${d.toStringAsFixed(1)} ${suffixes[i]}';
  }


  // --- Parsing & restore ---

  Future<Map<String, List<Map<String, dynamic>>>> parseBackup(String raw, {String? password}) async {
    final l10n = await loadAppL10n();
    Map<String, dynamic> root;
    try {
      root = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw BackupException(l10n.backupInvalidFile);
    }

    final format = root['format'];
    if (format == backupEncryptionMarker) {
      if (password == null || password.isEmpty) {
        throw BackupException(l10n.backupNeedsPassword);
      }
      final payload = root['payload'];
      if (payload is! String) throw BackupException(l10n.backupEncryptedInvalid);
      String decrypted;
      try {
        decrypted = CryptoUtils.decryptData(payload, password);
      } catch (_) {
        throw BackupException(l10n.backupWrongPassword);
      }
      try {
        root = jsonDecode(decrypted) as Map<String, dynamic>;
      } catch (_) {
        throw BackupException(l10n.backupEncryptedCorrupt);
      }
    } else if (format != backupFormatIdentifier) {
      throw BackupException(l10n.backupUnknownFormat);
    }

    final schemaVersion = root['schemaVersion'];
    if (schemaVersion is! int) throw BackupException(l10n.backupSchemaInvalid);
    if (schemaVersion > AppConstants.backupSchemaVersion) {
      throw BackupException(l10n.backupFromNewerVersion(schemaVersion));
    }

    final data = root['data'];
    if (data is! Map<String, dynamic>) throw BackupException(l10n.backupDataCorrupt);

    return data.map((key, value) {
      final rows = value;
      if (rows is! List) {
        throw BackupException(l10n.backupCollectionCorrupt(key));
      }
      return MapEntry(key, rows.whereType<Map<String, dynamic>>().toList());
    });
  }

  bool hasUnknownCollections(Map<String, List<Map<String, dynamic>>> data) {
    final known = _collections.keys.toSet();
    return data.keys.any((k) => !known.contains(k));
  }

  Future<int> restoreBackup(
    db.AppDatabase database,
    Map<String, List<Map<String, dynamic>>> data,
  ) async {
    await database.transaction(() async {
      for (final entry in _collections.entries) {
        final rows = data[entry.key] ?? const <Map<String, dynamic>>[];
        await database.delete(entry.value.table(database)).go();
        for (final row in rows) {
          await database.into(entry.value.table(database)).insert(entry.value.fromJson(row));
        }
      }
    });
    return data.values.fold<int>(0, (sum, rows) => sum + rows.length);
  }

  // --- Safety snapshot ---

  Future<void> createSafetySnapshot(db.AppDatabase database) async {
    final json = await generateBackup(database);
    final dir = await _safetyDir();
    final file = File('${dir.path}/safety-snapshot.json');
    await file.writeAsString(json);
  }

  Future<void> deleteSafetySnapshot() async {
    final dir = await _safetyDir();
    final file = File('${dir.path}/safety-snapshot.json');
    if (await file.exists()) await file.delete();
  }

  Future<void> rollbackFromSafetySnapshot(db.AppDatabase database) async {
    final dir = await _safetyDir();
    final file = File('${dir.path}/safety-snapshot.json');
    if (!await file.exists()) {
      throw BackupException((await loadAppL10n()).backupSnapshotMissing);
    }
    final raw = await file.readAsString();
    final data = await parseBackup(raw);
    await restoreBackup(database, data);
    await file.delete();
  }

  Future<Directory> _safetyDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/backup_snapshots');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // --- Internals ---

  Future<Map<String, List<Map<String, dynamic>>>> _collectAll(db.AppDatabase database) async {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final entry in _collections.entries) {
      final rows = await database.select(entry.value.table(database)).get();
      map[entry.key] = rows.map((r) => entry.value.toJson(r)).toList();
    }
    return map;
  }
}

class _Collection {
  final dynamic Function(db.AppDatabase) table;
  final Map<String, dynamic> Function(dynamic row) toJson;
  final dynamic Function(Map<String, dynamic>) fromJson;
  const _Collection(this.table, this.toJson, this.fromJson);
}

final Map<String, _Collection> _collections = {
  'accounts': _Collection(
    (d) => d.accountsTable,
    (r) => db.Account.fromJson(r.toJson()).toJson(),
    db.Account.fromJson,
  ),
  'categories': _Collection(
    (d) => d.categoriesTable,
    (r) => db.Category.fromJson(r.toJson()).toJson(),
    db.Category.fromJson,
  ),
  'transactions': _Collection(
    (d) => d.transactionsTable,
    (r) => db.Transaction.fromJson(r.toJson()).toJson(),
    db.Transaction.fromJson,
  ),
  'transfers': _Collection(
    (d) => d.transfersTable,
    (r) => db.Transfer.fromJson(r.toJson()).toJson(),
    db.Transfer.fromJson,
  ),
  'recurring_transactions': _Collection(
    (d) => d.recurringTransactionsTable,
    (r) => db.RecurringTransaction.fromJson(r.toJson()).toJson(),
    db.RecurringTransaction.fromJson,
  ),
  'budgets': _Collection(
    (d) => d.budgetsTable,
    (r) => db.Budget.fromJson(r.toJson()).toJson(),
    db.Budget.fromJson,
  ),
  'goals': _Collection(
    (d) => d.goalsTable,
    (r) => db.Goal.fromJson(r.toJson()).toJson(),
    db.Goal.fromJson,
  ),
  'debts': _Collection(
    (d) => d.debtsTable,
    (r) => db.Debt.fromJson(r.toJson()).toJson(),
    db.Debt.fromJson,
  ),
  'debt_payments': _Collection(
    (d) => d.debtPaymentsTable,
    (r) => db.DebtPayment.fromJson(r.toJson()).toJson(),
    db.DebtPayment.fromJson,
  ),
  'currencies': _Collection(
    (d) => d.currenciesTable,
    (r) => db.Currency.fromJson(r.toJson()).toJson(),
    db.Currency.fromJson,
  ),
  'exchange_rates': _Collection(
    (d) => d.exchangeRatesTable,
    (r) => db.ExchangeRate.fromJson(r.toJson()).toJson(),
    db.ExchangeRate.fromJson,
  ),
  'notes': _Collection(
    (d) => d.notesTable,
    (r) => db.Note.fromJson(r.toJson()).toJson(),
    db.Note.fromJson,
  ),
};

final backupServiceProvider = Provider<BackupService>((ref) => const BackupService());
