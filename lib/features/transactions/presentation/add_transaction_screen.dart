import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense'), icon: Icon(Icons.arrow_upward)),
                ButtonSegment(value: 'income', label: Text('Income'), icon: Icon(Icons.arrow_downward)),
              ],
              selected: {_type},
              onSelectionChanged: (sel) => setState(() => _type = sel.first),
            ),
            const SizedBox(height: 16),

            accountsAsync.when(
              data: (accounts) {
                final active = accounts.where((a) => !a.isArchived).toList();
                return DropdownButtonFormField<String>(
                  initialValue: _selectedAccountId,
                  hint: const Text('Select Account'),
                  items: active.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                  onChanged: (val) => setState(() => _selectedAccountId = val),
                  decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder()),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Accounts error: $e'),
            ),
            const SizedBox(height: 12),

            categoriesAsync.when(
              data: (categories) {
                final filtered = _type == 'income'
                    ? categories.where((c) => c.type == 'income').toList()
                    : categories.where((c) => c.type == 'expense').toList();
                return DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  hint: const Text('Select Category'),
                  items: filtered.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Categories error: $e'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              trailing: const Icon(Icons.calendar_today),
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
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const CircularProgressIndicator() : const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final amountText = _amountCtrl.text.trim();
    final amount = int.tryParse(amountText.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null || amount <= 0 || _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill amount and select an account')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final service = ref.read(transactionServiceProvider);
      if (_type == 'income') {
        await service.addIncome(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          amount: amount,
          currencyCode: 'IDR',
          date: _selectedDate,
          note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
        );
      } else {
        await service.addExpense(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          amount: amount,
          currencyCode: 'IDR',
          date: _selectedDate,
          note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
        );
      }
      ref.read(transactionsNotifierProvider.notifier).loadTransactions();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
