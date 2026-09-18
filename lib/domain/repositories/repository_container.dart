import 'package:money_manager/domain/repositories/account_repository.dart';
import 'package:money_manager/domain/repositories/budget_repository.dart';
import 'package:money_manager/domain/repositories/category_repository.dart';
import 'package:money_manager/domain/repositories/currency_repository.dart';
import 'package:money_manager/domain/repositories/debt_repository.dart';
import 'package:money_manager/domain/repositories/goal_repository.dart';
import 'package:money_manager/domain/repositories/recurring_repository.dart';
import 'package:money_manager/domain/repositories/transaction_repository.dart';

abstract class IRepositoryContainer {
  IAccountRepository get accounts;
  ICategoryRepository get categories;
  ITransactionRepository get transactions;
  IBudgetRepository get budgets;
  IGoalRepository get goals;
  IDebtRepository get debts;
  IRecurringRepository get recurring;
  ICurrencyRepository get currencies;
}
