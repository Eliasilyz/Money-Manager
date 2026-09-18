import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController(text: '0');
  final _noteCtrl = TextEditingController();
  String _accountType = 'wallet';
  String _currencyCode = 'IDR';
  bool _saving = false;

  static const _accountTypes = [
    ('wallet', 'Wallet', Icons.account_balance_wallet),
    ('savings', 'Savings', Icons.savings),
    ('credit', 'Credit Card', Icons.credit_card),
    ('cash', 'Cash', Icons.payments),
    ('investment', 'Investment', Icons.show_chart),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currenciesAsync = ref.watch(currenciesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g. BCA Savings',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),

            Text('Account Type', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _accountTypes.map((t) {
                final selected = _accountType == t.$1;
                return ChoiceChip(
                  label: Text(t.$2),
                  avatar: Icon(t.$3, size: 18),
                  selected: selected,
                  onSelected: (_) => setState(() => _accountType = t.$1),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            currenciesAsync.when(
              data: (currencies) {
                return DropdownButtonFormField<String>(
                  initialValue: _currencyCode,
                  items: currencies.map((c) => DropdownMenuItem(
                    value: c.code,
                    child: Text('${c.code} - ${c.name}'),
                  )).toList(),
                  onChanged: (val) => setState(() => _currencyCode = val ?? 'IDR'),
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monetization_on),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _balanceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Initial Balance',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(_saving ? 'Saving...' : 'Save Account'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an account name')),
      );
      return;
    }

    final balance = int.tryParse(_balanceCtrl.text.replaceAll(RegExp(r'[^0-9\-]'), '')) ?? 0;

    setState(() => _saving = true);
    try {
      await ref.read(accountsNotifierProvider.notifier).addAccount(
        name: name,
        accountType: _accountType,
        currencyCode: _currencyCode,
        initialBalance: balance,
        note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
