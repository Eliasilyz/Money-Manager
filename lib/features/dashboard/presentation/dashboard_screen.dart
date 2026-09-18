import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Money Manager')),
      body: dashboardAsync.when(
        data: (data) {
          final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BalanceCard(
                    balance: fmt.format(data.totalBalance),
                    income: fmt.format(data.totalIncome),
                    expenses: fmt.format(data.totalExpenses),
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(title: 'Accounts', onSeeAll: () => context.push('/accounts')),
                  const SizedBox(height: 8),
                  if (data.accounts.isEmpty)
                    const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No accounts yet')))
                  else
                    ...data.accounts.take(3).map((a) => Card(
                          child: ListTile(
                            title: Text(a.name),
                            subtitle: Text('${a.currencyCode} · ${a.accountType}'),
                            trailing: Text(fmt.format(a.initialBalance)),
                          ),
                        )),
                  const SizedBox(height: 16),
                  _SectionHeader(title: 'Recent Transactions', onSeeAll: () => context.push('/transactions')),
                  const SizedBox(height: 8),
                  if (data.recentTransactions.isEmpty)
                    const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No transactions yet')))
                  else
                    ...data.recentTransactions.map((t) {
                      final isIncome = t.type == 'income';
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isIncome ? Colors.green : Colors.red,
                          ),
                          title: Text(t.description ?? t.note ?? t.type),
                          subtitle: Text(DateFormat('dd MMM yyyy').format(t.date)),
                          trailing: Text(
                            '${isIncome ? '+' : '-'}${fmt.format(t.amount)}',
                            style: TextStyle(
                              color: isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                  _QuickActionsGrid(),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String balance;
  final String income;
  final String expenses;

  const _BalanceCard({required this.balance, required this.income, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Total Balance', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(balance, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.arrow_downward, color: Colors.green, size: 16),
                    const SizedBox(height: 4),
                    Text(income, style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                    Text('Income', style: theme.textTheme.bodySmall),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.arrow_upward, color: Colors.red, size: 16),
                    const SizedBox(height: 4),
                    Text(expenses, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600)),
                    Text('Expenses', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2,
      children: [
        _ActionTile(icon: Icons.receipt_long, label: 'Transactions', onTap: () => context.push('/transactions')),
        _ActionTile(icon: Icons.swap_horiz, label: 'Transfers', onTap: () => context.push('/transfers')),
        _ActionTile(icon: Icons.account_balance_wallet, label: 'Budgets', onTap: () => context.push('/budgets')),
        _ActionTile(icon: Icons.flag, label: 'Goals', onTap: () => context.push('/goals')),
        _ActionTile(icon: Icons.money_off, label: 'Debts', onTap: () => context.push('/debts')),
        _ActionTile(icon: Icons.repeat, label: 'Recurring', onTap: () => context.push('/recurring')),
        _ActionTile(icon: Icons.category, label: 'Categories', onTap: () => context.push('/categories')),
        _ActionTile(icon: Icons.monetization_on, label: 'Currencies', onTap: () => context.push('/currencies')),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
