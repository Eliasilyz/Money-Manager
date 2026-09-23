import 'package:drift/drift.dart';
import 'package:money_manager/database/database.dart' as drift;
import 'package:money_manager/domain/entities/recurring_transaction.dart' as domain;
import 'package:money_manager/domain/repositories/recurring_repository.dart';

class DriftRecurringRepository implements IRecurringRepository {
  final drift.AppDatabase _db;

  DriftRecurringRepository(this._db);

  @override
  Future<List<domain.RecurringTransaction>> getAllRecurring() async {
    final list = await _db.recurringDao.getAllRecurring();
    return list.map(_toDomain).toList();
  }

  @override
  Stream<List<domain.RecurringTransaction>> watchAllRecurring() =>
      _db.recurringDao.watchAllRecurring().map((list) =>
          list.map(_toDomain).toList());

  @override
  Stream<List<domain.RecurringTransaction>> watchDueRecurring(DateTime now) =>
      _db.recurringDao.watchDueRecurring(now).map((list) =>
          list.map(_toDomain).toList());

  @override
  Future<void> insertRecurring(domain.RecurringTransaction recurring) async {
    await _db.recurringDao.insertRecurring(
      drift.RecurringTransactionsTableCompanion.insert(
        id: recurring.id,
        type: recurring.type,
        accountId: recurring.accountId,
        categoryId: Value(recurring.categoryId),
        amount: recurring.amount,
        currencyCode: recurring.currencyCode,
        description: Value(recurring.description),
        frequency: recurring.frequency,
        interval: Value(recurring.interval),
        startDate: recurring.startDate,
        endDate: Value(recurring.endDate),
        nextOccurrence: recurring.nextOccurrence,
        enabled: Value(recurring.enabled),
        createdAt: Value(recurring.createdAt),
        updatedAt: Value(recurring.updatedAt),
      ),
    );
  }

  @override
  Future<void> updateRecurring(domain.RecurringTransaction recurring) async {
    await _db.recurringDao.updateRecurring(
      drift.RecurringTransactionsTableCompanion(
        id: Value(recurring.id),
        type: Value(recurring.type),
        accountId: Value(recurring.accountId),
        categoryId: Value(recurring.categoryId),
        amount: Value(recurring.amount),
        currencyCode: Value(recurring.currencyCode),
        description: Value(recurring.description),
        frequency: Value(recurring.frequency),
        interval: Value(recurring.interval),
        startDate: Value(recurring.startDate),
        endDate: Value(recurring.endDate),
        nextOccurrence: Value(recurring.nextOccurrence),
        enabled: Value(recurring.enabled),
      ),
    );
  }

  @override
  Future<void> deleteRecurring(String id) async {
    await _db.recurringDao.deleteRecurring(id);
  }

  domain.RecurringTransaction _toDomain(drift.RecurringTransaction r) =>
      domain.RecurringTransaction(
        id: r.id,
        type: r.type,
        accountId: r.accountId,
        categoryId: r.categoryId,
        amount: r.amount,
        currencyCode: r.currencyCode,
        description: r.description,
        frequency: r.frequency,
        interval: r.interval,
        startDate: r.startDate,
        endDate: r.endDate,
        nextOccurrence: r.nextOccurrence,
        enabled: r.enabled,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );
}