import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:money_manager/domain/entities/goal.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime? _targetDate;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Goal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Goal Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _targetCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Date'),
              subtitle: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context, initialDate: _startDate,
                  firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _startDate = picked);
              },
            ),
            const SizedBox(height: 12),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Target Date (optional)'),
              subtitle: Text(_targetDate != null ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}' : 'Not set'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context, initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) setState(() => _targetDate = picked);
              },
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const CircularProgressIndicator() : const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final target = int.tryParse(_targetCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (name.isEmpty || target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill name and target amount')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final goal = Goal(
        id: const Uuid().v4(),
        name: name,
        targetAmount: target,
        currencyCode: 'IDR',
        startDate: _startDate,
        targetDate: _targetDate,
        note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(goalsNotifierProvider.notifier).addGoal(goal);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
