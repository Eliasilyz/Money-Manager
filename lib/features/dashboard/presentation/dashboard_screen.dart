import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
import 'package:money_manager/theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _periods = [
    (DashboardPeriod.thisMonth, 'Bulan Ini'),
    (DashboardPeriod.threeMonths, '3 Bulan Terakhir'),
    (DashboardPeriod.thisYear, 'Tahun Ini'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final currentPeriod = ref.watch(dashboardPeriodProvider);

    return Scaffold(
      body: SafeArea(
        child: dashboardAsync.when(
          data: (data) {
            final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(dashboardProvider),
              color: AppColors.gold,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    _buildBalanceCard(context, data, fmt),
                    const SizedBox(height: 16),
                    _buildPeriodSelector(ref, currentPeriod),
                    const SizedBox(height: 16),
                    if (data.expenseBreakdown.isNotEmpty)
                      _buildExpenseChart(context, data.expenseBreakdown),
                    const SizedBox(height: 24),
                    _buildSection(context, 'Pemasukan & Pengeluaran'),
                    _buildStatRow(context, data),
                    const SizedBox(height: 24),
                    _buildSection(context, 'Transaksi Terakhir'),
                    if (data.recentTransactions.isEmpty)
                      _buildEmpty(context, 'Belum ada transaksi')
                    else
                      ...data.recentTransactions.map((t) => _buildTransactionTile(context, t, fmt)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Pagi 👋',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                'Money Manager',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.lilac, AppColors.sky],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, DashboardData data, NumberFormat fmt) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.gold.withValues(alpha: 0.08), AppColors.gold.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL SALDO', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted, letterSpacing: 0.8)),
              const SizedBox(height: 6),
              Text(fmt.format(data.totalBalance), style: GoogleFonts.jetBrainsMono(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildMiniStat(Icons.arrow_downward, 'Pemasukan', fmt.format(data.totalIncome), AppColors.teal)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMiniStat(Icons.arrow_upward, 'Pengeluaran', fmt.format(data.totalExpenses), AppColors.rose)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(WidgetRef ref, DashboardPeriod current) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
                onTap: () => ref.read(dashboardPeriodProvider.notifier).state = p.$1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
      ),
    );
  }

  Widget _buildExpenseChart(BuildContext context, List<CategoryExpense> breakdown) {
    final total = breakdown.fold<int>(0, (sum, e) => sum + e.amount);
    if (total == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: breakdown.map((e) {
                  final pct = e.amount / total;
                  return PieChartSectionData(
                    value: e.amount.toDouble(),
                    color: _getCategoryColor(e.categoryName),
                    title: pct > 0.05 ? '${(pct * 100).toStringAsFixed(0)}%' : '',
                    titleStyle: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    radius: 28,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total: ${NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0).format(total)}',
                      style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  ...breakdown.map((e) => _buildLegendItem(e)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String name) {
    final colors = [AppColors.gold, AppColors.teal, AppColors.rose, AppColors.sky, AppColors.lilac, AppColors.orange];
    final index = name.hashCode % colors.length;
    return colors[index.abs()];
  }

  Widget _buildLegendItem(CategoryExpense e) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _getCategoryColor(e.categoryName))),
          const SizedBox(width: 6),
          Expanded(child: Text(e.categoryName, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted), overflow: TextOverflow.ellipsis)),
          Text(NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0).format(e.amount),
              style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, DashboardData data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(icon: Icons.arrow_downward_rounded, label: 'Pemasukan', value: NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0).format(data.totalIncome), color: AppColors.teal),
          _StatItem(icon: Icons.arrow_upward_rounded, label: 'Pengeluaran', value: NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0).format(data.totalExpenses), color: AppColors.rose),
          _StatItem(icon: Icons.trending_up_rounded, label: 'Saldo', value: NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0).format(data.totalBalance), color: AppColors.gold),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.8)),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(child: Column(children: [const Text('📭', style: TextStyle(fontSize: 48)), const SizedBox(height: 12), Text(message, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14))])),
    );
  }

  Widget _buildTransactionTile(BuildContext context, Transaction t, NumberFormat fmt) {
    final isIncome = t.type == 'income';
    final color = isIncome ? AppColors.teal : AppColors.rose;
    final sign = isIncome ? '+' : '-';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: color, size: 18),
          ),
          title: Text(t.description ?? 'No description', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (t.note != null && t.note!.isNotEmpty)
                Text(t.note!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(DateFormat('dd MMM yyyy, HH:mm').format(t.date), style: GoogleFonts.inter(fontSize: 10, color: AppColors.textDim)),
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$sign${fmt.format(t.amount)}', style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
              const SizedBox(height: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, String value, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 24, height: 24, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)), child: Icon(icon, color: color, size: 12)),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
        Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    ]);
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatItem({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 16)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}
