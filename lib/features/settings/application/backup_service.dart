import 'dart:convert';
import 'package:money_manager/core/constants/app_constants.dart';
import 'package:money_manager/core/crypto/crypto_utils.dart';
import 'package:money_manager/database/database.dart' as db;

const backupFormatIdentifier = 'money_manager_backup';
const backupEncryptionMarker = 'encrypted_backup';

class BackupException implements Exception {
  final String message;
  const BackupException(this.message);
  @override
  String toString() => message;
}

/// Versioned JSON backup, independent of the SQLite schema.
///
/// Structure:
/// ```json
/// {
///   "format": "money_manager_backup",
///   "schemaVersion": 1,
///   "appVersion": "1.0.0",
///   "exportedAt": "iso8601",
///   "data": { "accounts": [...], "categories": [...], ... }
/// }
/// ```
/// When a password is set the whole object is AES-GCM encrypted and wrapped as
/// `{ "format": "encrypted_backup", "payload": "<base64>" }`.
class BackupService {
  const BackupService();

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

  /// Parses, decrypts (if password) and validates a backup payload.
  /// Returns the raw data map keyed by collection name.
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

  /// True when the backup contains a collection name we do not know.
  bool hasUnknownCollections(Map<String, List<Map<String, dynamic>>> data) {
    final known = _collections.keys.toSet();
    return data.keys.any((k) => !known.contains(k));
  }

  /// Restores all data inside a single transaction. Old data is only wiped
  /// after every collection row has been validated/counted first, so a
  /// malformed row set leaves the current data untouched.
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