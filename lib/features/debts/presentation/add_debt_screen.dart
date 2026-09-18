import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:money_manager/domain/entities/debt.dart';
import 'package:money_manager/features/debts/application/debt_provider.dart';

class AddDebtScreen extends ConsumerStatefulWidget {
  const AddDebtScreen({super.key});

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _personCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _type = 'borrowed';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _saving = false;

  @override
  void dispose() {
    _personCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Debt')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'borrowed', label: Text('Borrowed'), icon: Icon(Icons.trending_up)),
                ButtonSegment(value: 'lent', label: Text('Lent'), icon: Icon(Icons.trending_down)),
              ],
              selected: {_type},
              onSelectionChanged: (sel) => setState(() => _type = sel.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _personCtrl,
              decoration: const InputDecoration(labelText: 'Person Name', border: OutlineInputBorder()),
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
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due Date'),
              subtitle: Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const CircularProgressIndicator() : const Text('Save Debt'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final person = _personCtrl.text.trim();
    final amount = int.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (person.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill person name and amount')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final debt = Debt(
        id: const Uuid().v4(),
        personName: person,
        type: _type,
        originalAmount: amount,
        remainingAmount: amount,
        currencyCode: 'IDR',
        description: _descCtrl.text.isNotEmpty ? _descCtrl.text : null,
        dueDate: _dueDate,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(debtsNotifierProvider.notifier).addDebt(debt);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
