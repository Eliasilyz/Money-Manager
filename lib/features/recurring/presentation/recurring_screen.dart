import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/features/recurring/application/recurring_provider.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(recurringTransactionsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: asyncItems.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No recurring transactions set.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final rt = items[index];
              return SwitchListTile(
                secondary: const Icon(Icons.repeat),
                title: Text('${rt.frequency} every ${rt.interval}'),
                subtitle: Text('Next: ${rt.nextOccurrence.day}/${rt.nextOccurrence.month}/${rt.nextOccurrence.year}'),
                value: rt.enabled,
                onChanged: (_) => ref.read(recurringTransactionsNotifierProvider.notifier).toggle(rt),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
