import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/theme/app_theme.dart';

enum TxPeriod { thisMonth, threeMonths, thisYear, all }

final txPeriodProvider = StateProvider<TxPeriod>((ref) => TxPeriod.thisMonth);

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  static const _periods = [
    (TxPeriod.thisMonth, 'Bulan Ini'),
    (TxPeriod.threeMonths, '3 Bulan'),
    (TxPeriod.thisYear, 'Tahun Ini'),
    (TxPeriod.all, 'Semua'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final currentPeriod = ref.watch(txPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: transactionsAsync.when(
          data: (allTransactions) {
            final now = DateTime.now();
            final transactions = allTransactions.where((t) {
              switch (currentPeriod) {
                case TxPeriod.thisMonth:
                  return t.date.isAfter(DateTime(now.year, now.month, 1).subtract(const Duration(seconds: 1)));
                case TxPeriod.threeMonths:
                  return t.date.isAfter(DateTime(now.year, now.month - 3, 1).subtract(const Duration(seconds: 1)));
                case TxPeriod.thisYear:
                  return t.date.isAfter(DateTime(now.year, 1, 1).subtract(const Duration(seconds: 1)));
                case TxPeriod.all:
                  return true;
              }
            }).toList();

            final categories = categoriesAsync.valueOrNull ?? [];
            final catMap = {for (final c in categories) c.id: c};

            final expenses = transactions.where((t) => t.type == 'expense').toList();
            final totalExpense = expenses.fold<int>(0, (sum, t) => sum + t.amount);
            final totalIncome = transactions.where((t) => t.type == 'income').fold<int>(0, (sum, t) => sum + t.amount);

            final expenseByCat = <String, int>{};
            for (final t in expenses) {
              final catName = t.categoryId != null ? catMap[t.categoryId]?.name ?? 'Lainnya' : 'Tanpa Kategori';
              expenseByCat[catName] = (expenseByCat[catName] ?? 0) + t.amount;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(ref, currentPeriod),
                  const SizedBox(height: 16),
                  _buildSummaryCard(totalIncome, totalExpense),
                  const SizedBox(height: 16),
                  if (expenseByCat.isNotEmpty) ...[
                    _buildChart(expenseByCat, totalExpense),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    'RIWAYAT TRANSAKSI',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  if (transactions.isEmpty)
                    _buildEmpty()
                  else
                    ...transactions.map((tx) => _buildTxTile(context, ref, tx, catMap)),
                ],
              ),
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

  Widget _buildPeriodSelector(WidgetRef ref, TxPeriod current) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: _periods.map((p) {
          final selected = current == p.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(txPeriodProvider.notifier).state = p.$1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    p.$2,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppColors.bg : AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCard(int income, int expense) {
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.teal)),
                    const SizedBox(width: 6),
                    Text('Pemasukan', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(fmt.format(income), style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.teal), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.rose)),
                    const SizedBox(width: 6),
                    Text('Pengeluaran', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(fmt.format(expense), style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.rose), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(Map<String, int> expenseByCat, int total) {
    if (total == 0) return const SizedBox.shrink();
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    final colors = [AppColors.gold, AppColors.rose, AppColors.sky, AppColors.lilac, AppColors.orange, AppColors.teal];
    final entries = expenseByCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PENGELUARAN PER KATEGORI', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 32,
                      sections: entries.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final e = entry.value;
                        final pct = e.value / total;
                        return PieChartSectionData(
                          value: e.value.toDouble(),
                          color: colors[idx % colors.length],
                          title: pct > 0.06 ? '${(pct * 100).toStringAsFixed(0)}%' : '',
                          titleStyle: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          radius: 26,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entries.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final e = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: colors[idx % colors.length])),
                              const SizedBox(width: 6),
                              Expanded(child: Text(e.key, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted), overflow: TextOverflow.ellipsis)),
                              Text(fmt.format(e.value), style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTxTile(BuildContext context, WidgetRef ref, Transaction tx, Map<String, Category> catMap) {
    final isIncome = tx.type == 'income';
    final color = isIncome ? AppColors.teal : AppColors.rose;
    final sign = isIncome ? '+' : '-';
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    final cat = tx.categoryId != null ? catMap[tx.categoryId] : null;
    final title = (tx.description != null && tx.description!.isNotEmpty)
        ? tx.description!
        : (cat?.name ?? (isIncome ? 'Pemasukan' : 'Pengeluaran'));

    final subtitleParts = <String>[];
    if (cat != null && tx.description != null && tx.description!.isNotEmpty) {
      subtitleParts.add(cat.name);
    }
    if (tx.note != null && tx.note!.isNotEmpty) {
      subtitleParts.add(tx.note!);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitleParts.isNotEmpty)
                Text(
                  subtitleParts.join(' · '),
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 10, color: AppColors.textDim),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(tx.date),
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.textDim),
                  ),
                ],
              ),
            ],
          ),
          trailing: Text(
            '$sign${fmt.format(tx.amount)}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
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
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const Text('🧾', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Belum ada transaksi', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
