import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Manage'),
          _SettingsTile(
            icon: Icons.account_balance_wallet,
            title: 'Accounts',
            subtitle: 'Manage your bank accounts and wallets',
            onTap: () => context.push('/accounts'),
          ),
          _SettingsTile(
            icon: Icons.category,
            title: 'Categories',
            subtitle: 'Manage income and expense categories',
            onTap: () => context.push('/categories'),
          ),
          _SettingsTile(
            icon: Icons.monetization_on,
            title: 'Currencies',
            subtitle: 'View supported currencies',
            onTap: () => context.push('/currencies'),
          ),
          _SettingsTile(
            icon: Icons.repeat,
            title: 'Recurring Transactions',
            subtitle: 'Manage recurring income and expenses',
            onTap: () => context.push('/recurring'),
          ),
          const Divider(height: 1),
          const _SectionHeader(title: 'About'),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
            ),
            title: const Text('Money Manager', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Personal Finance Tracker'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'A simple and powerful personal finance app. Track your income, expenses, '
              'transfers, budgets, savings goals, and debts all in one place. '
              'Built with Flutter and Drift (SQLite) for a fast, offline-first experience.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0 (Build 1)'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Built with'),
            subtitle: Text('Flutter · Drift · Riverpod · go_router'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
