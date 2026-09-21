import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/features/accounts/presentation/accounts_screen.dart';
import 'package:money_manager/features/accounts/presentation/add_account_screen.dart';
import 'package:money_manager/features/accounts/presentation/manage_accounts_screen.dart';
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
import 'package:money_manager/features/notes/presentation/notes_screen.dart';
import 'package:money_manager/features/recurring/presentation/recurring_screen.dart';
import 'package:money_manager/features/security/presentation/security_screen.dart';
import 'package:money_manager/features/settings/presentation/backup_screen.dart';
import 'package:money_manager/features/settings/presentation/notification_settings_screen.dart';
import 'package:money_manager/features/settings/presentation/settings_screen.dart';
import 'package:money_manager/features/calendar/presentation/calendar_screen.dart';
import 'package:money_manager/features/statistics/presentation/statistics_screen.dart';
import 'package:money_manager/domain/entities/transaction.dart';
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
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) {
          final transaction = state.extra as Transaction?;
          return AddTransactionScreen(transaction: transaction);
        },
      ),
      GoRoute(
        path: '/add-account',
        builder: (context, state) {
          final account = state.extra as dynamic;
          return AddAccountScreen(editAccount: account);
        },
      ),
      GoRoute(path: '/manage-accounts', builder: (context, state) => const ManageAccountsScreen()),
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
      GoRoute(path: '/notes', builder: (context, state) => const NotesScreen()),
      GoRoute(path: '/backup', builder: (context, state) => const BackupScreen()),
      GoRoute(path: '/security', builder: (context, state) => const SecurityScreen()),
      GoRoute(path: '/recurring', builder: (context, state) => const RecurringScreen()),
      GoRoute(path: '/currencies', builder: (context, state) => const CurrenciesScreen()),
      GoRoute(path: '/notification-settings', builder: (context, state) => const NotificationSettingsScreen()),
      GoRoute(path: '/statistics', builder: (context, state) => const StatisticsScreen()),
      GoRoute(path: '/calendar', builder: (context, state) => const CalendarScreen()),
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
      bottomNavigationBar: AppBottomNav(navigationShell: navigationShell),
    );
  }
}
