import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';

class CurrenciesScreen extends ConsumerWidget {
  const CurrenciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCurrencies = ref.watch(currenciesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Currencies')),
      body: asyncCurrencies.when(
        data: (currencies) {
          if (currencies.isEmpty) {
            return const Center(child: Text('No currencies available.'));
          }
          return ListView.builder(
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final c = currencies[index];
              return ListTile(
                leading: CircleAvatar(child: Text(c.symbol)),
                title: Text('${c.code} - ${c.name}'),
                subtitle: Text('Symbol: ${c.symbol} · Decimals: ${c.decimalDigits}'),
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
