import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) {
            return const Center(child: Text('No budgets set. Tap + to create one.'));
          }
          return ListView.builder(
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final b = budgets[index];
              final catName = categoriesAsync.whenOrNull(
                data: (cats) => cats.where((c) => c.id == b.categoryId).map((c) => c.name).firstOrNull ?? b.categoryId,
              ) ?? b.categoryId;

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.account_balance_wallet)),
                title: Text(catName),
                subtitle: Text('${b.period} · ${DateFormat('dd MMM yyyy').format(b.startDate)}'),
                trailing: Text(
                  NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0).format(b.amount),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-budget'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
