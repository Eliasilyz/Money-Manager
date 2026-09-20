import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
import 'package:money_manager/theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () => context.push('/add-transaction'),
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.bg,
        child: const Icon(Icons.add),
      ),
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
                    _buildQuickStats(context, data, fmt),
                    const SizedBox(height: 24),
                    _buildSection(context, 'Transaksi Terakhir', () => context.push('/transactions')),
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
    final colors = AppColorsT.of(context);
    final now = DateTime.now();
    final dateBadge = DateFormat('MMM yyyy', 'id').format(now);
    final greeting = now.hour < 12
        ? 'Selamat pagi'
        : now.hour < 17
            ? 'Selamat siang'
            : 'Selamat malam';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting 👋',
                style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                'Money Manager',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: colors.textPrimary),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              dateBadge,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, DashboardData data, NumberFormat fmt) {
    final colors = AppColorsT.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryDark, colors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total saldo',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 8),
          Text(
            fmt.format(data.totalBalance),
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat(context, Icons.arrow_downward_rounded, 'Pemasukan bulan ini', fmt.format(data.totalIncome), true),
              const SizedBox(width: 16),
              _buildMiniStat(context, Icons.arrow_upward_rounded, 'Pengeluaran', fmt.format(data.totalExpenses), false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, IconData icon, String label, String value, bool isIncome) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.6)), overflow: TextOverflow.ellipsis),
                Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, DashboardData data, NumberFormat fmt) {
    final colors = AppColorsT.of(context);
    final today = data.recentTransactions.where((t) {
      final now = DateTime.now();
      return t.date.year == now.year && t.date.month == now.month && t.date.day == now.day;
    });
    final todayAmount = today.fold<int>(0, (sum, t) {
      return sum + (t.type == 'income' ? t.amount : -t.amount);
    });
    final monthExpenses = data.totalExpenses;

    final stats = [
      _QuickStat('Hari ini', fmt.format(todayAmount.abs()), AppColors.teal),
      _QuickStat('Bulan ini', fmt.format(monthExpenses), AppColors.gold),
      _QuickStat('Total', fmt.format(data.totalBalance), AppColors.lilac),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.label, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    s.value,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, VoidCallback? onSeeAll) {
    final colors = AppColorsT.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text('Lihat semua', style: GoogleFonts.inter(fontSize: 12, color: colors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, Transaction t, NumberFormat fmt) {
    final colors = AppColorsT.of(context);
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
          title: Text(
            (t.description != null && t.description!.isNotEmpty) ? t.description! : (isIncome ? 'Pemasukan' : 'Pengeluaran'),
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (t.note != null && t.note!.isNotEmpty)
                Text(t.note!, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
              const SizedBox(height: 2),
              Text(DateFormat('dd MMM yyyy, HH:mm').format(t.date), style: GoogleFonts.inter(fontSize: 10, color: colors.textSecondary)),
            ],
          ),
          trailing: Text(
            '$sign${fmt.format(t.amount)}',
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String message) {
    final colors = AppColorsT.of(context);
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const Text('📭', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(message, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _QuickStat {
  final String label;
  final String value;
  final Color color;
  const _QuickStat(this.label, this.value, this.color);
}
