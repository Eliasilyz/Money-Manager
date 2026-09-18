import 'package:money_manager/domain/entities/transaction.dart';

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
}
