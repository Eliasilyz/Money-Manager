import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/theme/app_colors.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _period = 'Bulan';
  final _fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

  static const _catColors = <String, Color>{
    'makan': Color(0xFF1B6E4B),
    'minum': Color(0xFF3B82F6),
    'belanja': Color(0xFFF59E0B),
    'transportasi': Color(0xFFE0524A),
    'rumah': Color(0xFF8B5CF6),
    'hiburan': Color(0xFF10B981),
    'kesehatan': Color(0xFFE0524A),
    'pendidikan': Color(0xFF3B82F6),
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistik', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: transactionsAsync.when(
        data: (allTx) {
          final catMap = categoriesAsync.whenOrNull(data: (cats) => {for (final c in cats) c.id: c}) ?? <String, Category>{};
          final now = DateTime.now();
          final List<Transaction> periodTx;
          String periodLabel;

          switch (_period) {
            case 'Minggu':
              final weekStart = now.subtract(Duration(days: now.weekday - 1));
              periodTx = allTx.where((t) => t.date.isAfter(weekStart.subtract(const Duration(days: 1)))).toList();
              periodLabel = 'Minggu ini';
              break;
            case 'Tahun':
              periodTx = allTx.where((t) => t.date.year == now.year).toList();
              periodLabel = 'Tahun ${now.year}';
              break;
            default:
              periodTx = allTx.where((t) => t.date.month == now.month && t.date.year == now.year).toList();
              periodLabel = DateFormat('MMMM yyyy', 'id').format(now);
          }

          final income = periodTx.where((t) => t.type == 'income').fold<int>(0, (int sum, t) => sum + t.amount);
          final expense = periodTx.where((t) => t.type == 'expense').fold<int>(0, (int sum, t) => sum + t.amount);
          final diff = income - expense;

          // Category breakdown
          final catTotals = <String, int>{};
          for (final t in periodTx.where((t) => t.type == 'expense')) {
            final catId = t.categoryId;
            if (catId != null) {
              catTotals[catId] = (catTotals[catId] ?? 0) + t.amount;
            }
          }
          final sortedCats = catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
          final maxCat = sortedCats.isNotEmpty ? sortedCats.first.value : 1;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(periodLabel, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.primaryDark, colors.primary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ringkasan keuangan', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _heroStat('Pemasukan', income, Colors.white),
                        const SizedBox(width: 16),
                        _heroStat('Pengeluaran', expense, Colors.white),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Selisih', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
                    Text(
                      _fmt.format(diff),
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['Minggu', 'Bulan', 'Tahun'].map((p) {
                    final selected = _period == p;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _period = p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? colors.primary : colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? colors.primary : colors.border),
                          ),
                          child: Text(p, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.textPrimary)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              // Stat cards row
              Row(
                children: [
                  _statCard('Transaksi', '${periodTx.length}', colors),
                  const SizedBox(width: 12),
                  _statCard('Rata-rata/hari', _fmt.format(periodTx.isNotEmpty ? (expense / DateTime(now.year, now.month + 1, 0).day).round() : 0), colors),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pengeluaran per kategori', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                  Text('${sortedCats.length} kategori', style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              if (sortedCats.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.border)),
                  child: Text('Belum ada data pengeluaran', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary), textAlign: TextAlign.center),
                )
              else
                ...sortedCats.map((entry) {
                  final cat = catMap[entry.key];
                  final name = cat?.name ?? 'Lainnya';
                  final catColor = _catColors[name.toLowerCase()] ?? colors.primary;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                            Text(_fmt.format(entry.value), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (entry.value / maxCat).clamp(0.0, 1.0),
                            backgroundColor: colors.border,
                            color: catColor,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
    );
  }

  Widget _heroStat(String label, int value, Color textColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: textColor.withValues(alpha: 0.7))),
          Text(_fmt.format(value), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, AppColorsT colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary)),
          ],
        ),
      ),
    );
  }
}