import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/features/debts/application/debt_provider.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Debts')),
      body: debtsAsync.when(
        data: (debts) {
          if (debts.isEmpty) {
            return const Center(child: Text('No debts tracked. Tap + to add one.'));
          }
          return ListView.builder(
            itemCount: debts.length,
            itemBuilder: (context, index) {
              final d = debts[index];
              final isOverdue = d.status == 'unpaid' && d.dueDate.isBefore(DateTime.now());

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isOverdue ? Colors.red.shade50 : null,
                  child: Icon(d.type == 'borrowed' ? Icons.trending_up : Icons.trending_down),
                ),
                title: Text('${d.type == 'borrowed' ? 'Borrowed from' : 'Lent to'} ${d.personName}'),
                subtitle: Text('${d.remainingAmount} remaining · Due: ${d.dueDate.day}/${d.dueDate.month}/${d.dueDate.year}'),
                trailing: Text(
                  d.status.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: d.status == 'paid' ? Colors.green : (isOverdue ? Colors.red : Colors.orange),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-debt'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
