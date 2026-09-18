import 'package:drift/drift.dart';
import 'package:money_manager/database/database.dart' as drift;
import 'package:money_manager/domain/entities/debt.dart' as domain;
import 'package:money_manager/domain/repositories/debt_repository.dart';

class DriftDebtRepository implements IDebtRepository {
  final drift.AppDatabase _db;

  DriftDebtRepository(this._db);

  @override
  Future<List<domain.Debt>> getAllDebts() async {
    final debts = await _db.debtsDao.getAllDebts();
    return debts.map(_toDomainDebt).toList();
  }

  @override
  Stream<List<domain.Debt>> watchAllDebts() =>
      _db.debtsDao.watchAllDebts().map((debts) =>
          debts.map(_toDomainDebt).toList());

  @override
  Future<List<domain.Debt>> getOverdueDebts(DateTime now) async {
    final debts = await _db.debtsDao.getAllDebts();
    return debts
        .where((d) => d.dueDate.isBefore(now) && d.remainingAmount > 0 && d.status != 'paid')
        .map(_toDomainDebt)
        .toList();
  }

  @override
  Future<domain.Debt?> getDebtById(String id) async {
    final debt = await _db.debtsDao.getDebtById(id);
    if (debt == null) return null;
    return _toDomainDebt(debt);
  }

  @override
  Future<void> insertDebt(domain.Debt debt) async {
    await _db.debtsDao.insertDebt(
      drift.DebtsTableCompanion(
        id: Value(debt.id),
        personName: Value(debt.personName),
        type: Value(debt.type),
        originalAmount: Value(debt.originalAmount),
        remainingAmount: Value(debt.remainingAmount),
        currencyCode: Value(debt.currencyCode),
        description: Value(debt.description),
        dueDate: Value(debt.dueDate),
        status: Value(debt.status),
        createdAt: Value(debt.createdAt),
        updatedAt: Value(debt.updatedAt),
      ),
    );
  }

  @override
  Future<void> updateDebt(domain.Debt debt) async {
    await _db.debtsDao.updateDebt(
      drift.DebtsTableCompanion(
        id: Value(debt.id),
        personName: Value(debt.personName),
        type: Value(debt.type),
        originalAmount: Value(debt.originalAmount),
        remainingAmount: Value(debt.remainingAmount),
        currencyCode: Value(debt.currencyCode),
        description: Value(debt.description),
        dueDate: Value(debt.dueDate),
        status: Value(debt.status),
        createdAt: Value(debt.createdAt),
        updatedAt: Value(debt.updatedAt),
      ),
    );
  }

  @override
  Future<void> deleteDebt(String id) async {
    await _db.debtsDao.deleteDebt(id);
  }

  @override
  Future<List<domain.DebtPayment>> getPaymentsForDebt(String debtId) async {
    final payments = await _db.debtsDao.getPaymentsForDebt(debtId);
    return payments.map(_toDomainPayment).toList();
  }

  @override
  Stream<List<domain.DebtPayment>> watchPaymentsForDebt(String debtId) =>
      _db.debtsDao.watchPaymentsForDebt(debtId).map((payments) =>
          payments.map(_toDomainPayment).toList());

  @override
  Future<void> insertDebtPayment(domain.DebtPayment payment) async {
    await _db.debtsDao.insertDebtPayment(
      drift.DebtPaymentsTableCompanion(
        id: Value(payment.id),
        debtId: Value(payment.debtId),
        accountId: Value(payment.accountId),
        amount: Value(payment.amount),
        date: Value(payment.date),
        note: Value(payment.note),
        createdAt: Value(payment.createdAt),
      ),
    );
  }

  @override
  Future<int> getTotalPaidForDebt(String debtId) async {
    final payments = await _db.debtsDao.getPaymentsForDebt(debtId);
    return payments.fold<int>(0, (sum, p) => sum + p.amount);
  }

  domain.Debt _toDomainDebt(drift.Debt d) => domain.Debt(
        id: d.id,
        personName: d.personName,
        type: d.type,
        originalAmount: d.originalAmount,
        remainingAmount: d.remainingAmount,
        currencyCode: d.currencyCode,
        description: d.description,
        dueDate: d.dueDate,
        status: d.status,
        createdAt: d.createdAt,
        updatedAt: d.updatedAt,
      );

  domain.DebtPayment _toDomainPayment(drift.DebtPayment p) => domain.DebtPayment(
        id: p.id,
        debtId: p.debtId,
        accountId: p.accountId,
        amount: p.amount,
        date: p.date,
        note: p.note,
        createdAt: p.createdAt,
      );
}
