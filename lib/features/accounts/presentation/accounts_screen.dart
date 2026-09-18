import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text('No accounts yet. Tap + to create one.'));
          }
          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                title: Text(account.name),
                subtitle: Text('${account.currencyCode} · ${account.accountType}'),
                trailing: account.isArchived
                    ? const Icon(Icons.archive, size: 18)
                    : null,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAccountDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAccountDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final currencyCtrl = TextEditingController();
    final balanceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Account Type')),
              TextField(controller: currencyCtrl, decoration: const InputDecoration(labelText: 'Currency Code')),
              TextField(controller: balanceCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: false), decoration: const InputDecoration(labelText: 'Initial Balance')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text;
              final type = typeCtrl.text;
              final currency = currencyCtrl.text;
              final balance = int.tryParse(balanceCtrl.text) ?? 0;
              if (name.isNotEmpty && currency.isNotEmpty) {
                ref.read(accountsNotifierProvider.notifier).addAccount(
                      name: name, accountType: type, currencyCode: currency, initialBalance: balance,
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
