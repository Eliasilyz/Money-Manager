import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  String _type = 'expense';
  String? _selectedAccountId;
  String? _selectedCategoryId;
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    String? accountCurrency;
    if (_selectedAccountId != null) {
      accountsAsync.whenData((accounts) {
        final match = accounts.where((a) => a.id == _selectedAccountId);
        if (match.isNotEmpty) accountCurrency = match.first.currencyCode;
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense'), icon: Icon(Icons.arrow_upward)),
                ButtonSegment(value: 'income', label: Text('Income'), icon: Icon(Icons.arrow_downward)),
              ],
              selected: {_type},
              onSelectionChanged: (sel) => setState(() {
                _type = sel.first;
                _selectedCategoryId = null;
              }),
            ),
            const SizedBox(height: 20),

            accountsAsync.when(
              data: (accounts) {
                final active = accounts.where((a) => !a.isArchived).toList();
                if (active.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 32, color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text('No accounts yet'),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.push('/add-account'),
                            child: const Text('Create Account'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return DropdownButtonFormField<String>(
                  initialValue: _selectedAccountId,
                  hint: const Text('Select Account'),
                  items: active.map((a) => DropdownMenuItem(
                    value: a.id,
                    child: Text('${a.name} (${a.currencyCode})'),
                  )).toList(),
                  onChanged: (val) => setState(() {
                    _selectedAccountId = val;
                    _selectedCategoryId = null;
                  }),
                  decoration: const InputDecoration(
                    labelText: 'Account',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading accounts: $e'),
            ),
            const SizedBox(height: 16),

            categoriesAsync.when(
              data: (categories) {
                final filtered = _type == 'income'
                    ? categories.where((c) => c.type == 'income').toList()
                    : categories.where((c) => c.type == 'expense').toList();
                return DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  hint: const Text('Select Category (optional)'),
                  items: filtered.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading categories: $e'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
                prefixText: '${accountCurrency ?? 'IDR'} ',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(_formatDate(_selectedDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(_saving ? 'Saving...' : 'Save Transaction'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<void> _save() async {
    final amountText = _amountCtrl.text.trim();
    final amount = int.tryParse(amountText.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null || amount <= 0 || _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account and enter a valid amount')),
      );
      return;
    }

    String currencyCode = 'IDR';
    final accounts = ref.read(accountsNotifierProvider).valueOrNull ?? [];
    final match = accounts.where((a) => a.id == _selectedAccountId);
    if (match.isNotEmpty) currencyCode = match.first.currencyCode;

    setState(() => _saving = true);
    try {
      final service = ref.read(transactionServiceProvider);
      if (_type == 'income') {
        await service.addIncome(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          amount: amount,
          currencyCode: currencyCode,
          date: _selectedDate,
          note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
        );
      } else {
        await service.addExpense(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          amount: amount,
          currencyCode: currencyCode,
          date: _selectedDate,
          note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
        );
      }
      ref.read(transactionsNotifierProvider.notifier).loadTransactions();
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
