import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/features/accounts/presentation/accounts_screen.dart';
import 'package:money_manager/features/accounts/presentation/add_account_screen.dart';
import 'package:money_manager/features/budgets/presentation/budgets_screen.dart';
import 'package:money_manager/features/budgets/presentation/add_budget_screen.dart';
import 'package:money_manager/features/categories/presentation/categories_screen.dart';
import 'package:money_manager/features/categories/presentation/add_category_screen.dart';
import 'package:money_manager/features/currencies/presentation/currencies_screen.dart';
import 'package:money_manager/features/dashboard/presentation/dashboard_screen.dart';
import 'package:money_manager/features/debts/presentation/debts_screen.dart';
import 'package:money_manager/features/debts/presentation/add_debt_screen.dart';
import 'package:money_manager/features/goals/presentation/goals_screen.dart';
import 'package:money_manager/features/goals/presentation/add_goal_screen.dart';
import 'package:money_manager/features/recurring/presentation/recurring_screen.dart';
import 'package:money_manager/features/settings/presentation/settings_screen.dart';
import 'package:money_manager/features/transactions/presentation/transactions_screen.dart';
import 'package:money_manager/features/transactions/presentation/add_transaction_screen.dart';
import 'package:money_manager/features/transfers/presentation/transfers_screen.dart';
import 'package:money_manager/features/transfers/presentation/add_transfer_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/transactions', builder: (context, state) => const TransactionsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/accounts', builder: (context, state) => const AccountsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          ]),
        ],
      ),
      GoRoute(path: '/add-account', builder: (context, state) => const AddAccountScreen()),
      GoRoute(path: '/add-transaction', builder: (context, state) => const AddTransactionScreen()),
      GoRoute(path: '/transfers', builder: (context, state) => const TransfersScreen()),
      GoRoute(path: '/add-transfer', builder: (context, state) => const AddTransferScreen()),
      GoRoute(path: '/budgets', builder: (context, state) => const BudgetsScreen()),
      GoRoute(path: '/add-budget', builder: (context, state) => const AddBudgetScreen()),
      GoRoute(path: '/goals', builder: (context, state) => const GoalsScreen()),
      GoRoute(path: '/add-goal', builder: (context, state) => const AddGoalScreen()),
      GoRoute(path: '/debts', builder: (context, state) => const DebtsScreen()),
      GoRoute(path: '/add-debt', builder: (context, state) => const AddDebtScreen()),
      GoRoute(path: '/categories', builder: (context, state) => const CategoriesScreen()),
      GoRoute(path: '/add-category', builder: (context, state) => const AddCategoryScreen()),
      GoRoute(path: '/recurring', builder: (context, state) => const RecurringScreen()),
      GoRoute(path: '/currencies', builder: (context, state) => const CurrenciesScreen()),
    ],
  );
});

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Accounts'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
