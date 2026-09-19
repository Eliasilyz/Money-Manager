import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/theme/app_theme.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🧾', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text('Belum ada transaksi', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isIncome = tx.type == 'income';
                final color = isIncome ? AppColors.teal : AppColors.rose;
                final sign = isIncome ? '+' : '-';
                final amountText = NumberFormat.currency(
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(tx.amount);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: color,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        tx.description ?? (isIncome ? 'Pemasukan' : 'Pengeluaran'),
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tx.note != null && tx.note!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(tx.note!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textDim),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMM yyyy, HH:mm').format(tx.date),
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textDim),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Text(
                        '$sign$amountText',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      onLongPress: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Hapus Transaksi?'),
                            content: const Text('Transaksi ini akan dihapus permanen.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text('Hapus', style: GoogleFonts.inter(color: AppColors.rose)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          ref.read(transactionsNotifierProvider.notifier).deleteTransaction(tx.id);
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transactions_fab',
        onPressed: () => context.push('/add-transaction'),
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.bg,
        child: const Icon(Icons.add),
      ),
    );
  }
}
