import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:money_manager/core/constants/app_constants.dart';
import 'package:money_manager/core/crypto/crypto_utils.dart';
import 'package:money_manager/database/database.dart' as db;
import 'package:path_provider/path_provider.dart';

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

  /// Computes a hash of the current database state. Returns null if the hash
  /// matches the last recorded hash (i.e. no changes since last backup).
  Future<bool> shouldSkipBackup(db.AppDatabase database) async {
    final data = await _collectAll(database);
    final canonical = const JsonEncoder().convert(data);
    final hash = md5.convert(utf8.encode(canonical)).toString();
    final lastHash = await _readLastHash();
    return hash == lastHash;
  }

  Future<void> recordBackupSuccess() async {
    // TODO_FILL_ME: persist last backup time + data hash to SharedPreferences
  }

  Future<void> recordBackupFailure(String reason) async {
    // TODO_FILL_ME: persist failure reason + time to SharedPreferences
  }

  // --- Parsing & restore ---

  Map<String, List<Map<String, dynamic>>> parseBackup(String raw, {String? password}) {
    Map<String, dynamic> root;
    try {
      root = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw const BackupException('File bukan backup yang valid.');
    }

    final format = root['format'];
    if (format == backupEncryptionMarker) {
      if (password == null || password.isEmpty) {
        throw const BackupException('Backup terenkripsi memerlukan kata sandi.');
      }
      final payload = root['payload'];
      if (payload is! String) throw const BackupException('Backup terenkripsi tidak valid.');
      String decrypted;
      try {
        decrypted = CryptoUtils.decryptData(payload, password);
      } catch (_) {
        throw const BackupException('Kata sandi salah atau file rusak.');
      }
      try {
        root = jsonDecode(decrypted) as Map<String, dynamic>;
      } catch (_) {
        throw const BackupException('File backup terenkripsi rusak.');
      }
    } else if (format != backupFormatIdentifier) {
      throw const BackupException('Format backup tidak dikenali.');
    }

    final schemaVersion = root['schemaVersion'];
    if (schemaVersion is! int) throw const BackupException('Versi skema backup tidak valid.');
    if (schemaVersion > AppConstants.backupSchemaVersion) {
      throw BackupException(
        'Backup dibuat oleh versi yang lebih baru (skema $schemaVersion). Update aplikasi terlebih dahulu.',
      );
    }

    final data = root['data'];
    if (data is! Map<String, dynamic>) throw const BackupException('Data backup kosong atau rusak.');

    return data.map((key, value) {
      final rows = value;
      if (rows is! List) {
        throw BackupException('Koleksi "$key" pada backup rusak.');
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
      throw const BackupException('Snapshot cadangan tidak ditemukan.');
    }
    final raw = await file.readAsString();
    final data = parseBackup(raw);
    await restoreBackup(database, data);
    await file.delete();
  }

  Future<Directory> _safetyDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/backup_snapshots');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // --- Retention ---

  Future<void> trimOldBackups({int maxBackups = 5}) async {
    // TODO_FILL_ME: list backups on Drive, sort by date, delete oldest auto backups beyond maxBackups
  }

  Future<String> getDriveBackupSize() async {
    // TODO_FILL_ME: query total size from Drive
    return '0 B';
  }

  // --- Internals ---

  Future<String?> _readLastHash() async {
    // TODO_FILL_ME: read from SharedPreferences
    return null;
  }

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
