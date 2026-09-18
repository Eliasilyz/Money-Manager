import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/features/accounts/presentation/accounts_screen.dart';
import 'package:money_manager/features/budgets/presentation/budgets_screen.dart';
import 'package:money_manager/features/budgets/presentation/add_budget_screen.dart';
import 'package:money_manager/features/categories/presentation/categories_screen.dart';
import 'package:money_manager/features/goals/presentation/goals_screen.dart';
import 'package:money_manager/features/goals/presentation/add_goal_screen.dart';
import 'package:money_manager/features/debts/presentation/debts_screen.dart';
import 'package:money_manager/features/debts/presentation/add_debt_screen.dart';
import 'package:money_manager/features/recurring/presentation/recurring_screen.dart';
import 'package:money_manager/features/currencies/presentation/currencies_screen.dart';
import 'package:money_manager/features/dashboard/presentation/dashboard_screen.dart';
import 'package:money_manager/features/transactions/presentation/transactions_screen.dart';
import 'package:money_manager/features/transactions/presentation/add_transaction_screen.dart';
import 'package:money_manager/features/transfers/presentation/transfers_screen.dart';
import 'package:money_manager/features/transfers/presentation/add_transfer_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/accounts',
        name: 'accounts',
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        name: 'add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/transfers',
        name: 'transfers',
        builder: (context, state) => const TransfersScreen(),
      ),
      GoRoute(
        path: '/add-transfer',
        name: 'add-transfer',
        builder: (context, state) => const AddTransferScreen(),
      ),
      GoRoute(
        path: '/budgets',
        name: 'budgets',
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(
        path: '/add-budget',
        name: 'add-budget',
        builder: (context, state) => const AddBudgetScreen(),
      ),
      GoRoute(
        path: '/goals',
        name: 'goals',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/add-goal',
        name: 'add-goal',
        builder: (context, state) => const AddGoalScreen(),
      ),
      GoRoute(
        path: '/debts',
        name: 'debts',
        builder: (context, state) => const DebtsScreen(),
      ),
      GoRoute(
        path: '/add-debt',
        name: 'add-debt',
        builder: (context, state) => const AddDebtScreen(),
      ),
      GoRoute(
        path: '/recurring',
        name: 'recurring',
        builder: (context, state) => const RecurringScreen(),
      ),
      GoRoute(
        path: '/currencies',
        name: 'currencies',
        builder: (context, state) => const CurrenciesScreen(),
      ),
    ],
  );
});
