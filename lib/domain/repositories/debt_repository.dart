import 'package:money_manager/domain/entities/debt.dart';

abstract class IDebtRepository {
  Future<List<Debt>> getAllDebts();
  Stream<List<Debt>> watchAllDebts();
  Future<List<Debt>> getOverdueDebts(DateTime now);
  Future<Debt?> getDebtById(String id);
  Future<void> insertDebt(Debt debt);
  Future<void> updateDebt(Debt debt);
  Future<void> deleteDebt(String id);

  Future<List<DebtPayment>> getPaymentsForDebt(String debtId);
  Stream<List<DebtPayment>> watchPaymentsForDebt(String debtId);
  Future<void> insertDebtPayment(DebtPayment payment);
  Future<int> getTotalPaidForDebt(String debtId);
}
