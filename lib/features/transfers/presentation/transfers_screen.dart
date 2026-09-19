import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/transfers/application/transfer_provider.dart';

class TransfersScreen extends ConsumerWidget {
  const TransfersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfersAsync = ref.watch(transfersNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transfers')),
      body: transfersAsync.when(
        data: (transfers) {
          if (transfers.isEmpty) {
            return const Center(child: Text('No transfers yet.'));
          }
          return ListView.builder(
            itemCount: transfers.length,
            itemBuilder: (context, index) {
              final t = transfers[index];
              final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
                title: Text(t.description ?? 'Transfer'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(t.date)),
                trailing: Text(fmt.format(t.sourceAmount)),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transfers_fab',
        onPressed: () => context.push('/add-transfer'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
