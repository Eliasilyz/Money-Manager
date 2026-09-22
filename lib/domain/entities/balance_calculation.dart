import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/domain/entities/transfer.dart';

class BalanceCalculation {
  final int initialBalance;
  final List<Transaction> transactions;

  BalanceCalculation({required this.initialBalance, required this.transactions});

  int calculate() {
    var balance = initialBalance;
    for (final t in transactions) {
      if (t.type == 'income') {
        balance += t.amount;
      } else if (t.type == 'expense') {
        balance -= t.amount;
      }
    }
    return balance;
  }

  static int accountBalance({
    required int initialBalance,
    required String accountId,
    required List<Transaction> transactions,
    required List<Transfer> transfers,
  }) {
    var balance = initialBalance;
    for (final t in transactions) {
      if (t.accountId != accountId) continue;
      if (t.type == 'income') {
        balance += t.amount;
      } else if (t.type == 'expense') {
        balance -= t.amount;
      }
    }
    for (final tr in transfers) {
      if (tr.fromAccountId == accountId) balance -= tr.sourceAmount;
      if (tr.toAccountId == accountId) balance += tr.destinationAmount;
    }
    return balance;
  }
}
