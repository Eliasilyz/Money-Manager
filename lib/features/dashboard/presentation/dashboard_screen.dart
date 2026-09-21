import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
import 'package:money_manager/theme/app_colors.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () => context.push('/add-transaction'),
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 26),
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
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildCashFlow(context, data, fmt),
                    const SizedBox(height: 24),
                    _buildSection(context, 'Transaksi terbaru', () => context.push('/transactions')),
                    if (data.recentTransactions.isEmpty)
                      _buildEmpty(context)
                    else
                      ...data.recentTransactions.map((t) => _buildTxTile(context, t, fmt)),
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
    final greeting = now.hour < 12 ? 'Selamat pagi' : now.hour < 17 ? 'Selamat siang' : 'Selamat malam';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$greeting, Rani', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary)),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none_outlined, color: colors.textSecondary, size: 22),
            tooltip: 'Notifikasi',
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
        boxShadow: [BoxShadow(color: colors.primaryDark.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total saldo', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.7))),
              GestureDetector(
                onTap: () => setState(() => _showBalance = !_showBalance),
                child: Icon(_showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white.withValues(alpha: 0.7), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _showBalance ? fmt.format(data.totalBalance) : 'Rp ********',
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _heroMiniStat(AppColors.teal, 'Pemasukan bulan ini', fmt.format(data.totalIncome)),
              const SizedBox(width: 20),
              _heroMiniStat(AppColors.rose, 'Pengeluaran bulan ini', fmt.format(data.totalExpenses)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMiniStat(Color dotColor, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildQuickActions(BuildContext context) {
    final colors = AppColorsT.of(context);
    final actions = [
      (Icons.swap_horiz_rounded, 'Transfer'),
      (Icons.qr_code_scanner_rounded, 'Pindai'),
      (Icons.savings_outlined, 'Target'),
      (Icons.bar_chart_rounded, 'Laporan'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: actions.map((a) {
          return Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Column(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Icon(a.$1, color: colors.primary, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(a.$2, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCashFlow(BuildContext context, DashboardData data, NumberFormat fmt) {
    final colors = AppColorsT.of(context);
    final now = DateTime.now();
    final months = <String>[];
    final incomes = <double>[];
    final expenses = <double>[];
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      months.add(DateFormat('MMM', 'id').format(m));
      final monthTx = data.recentTransactions.where((t) => t.date.year == m.year && t.date.month == m.month);
      incomes.add(monthTx.where((t) => t.type == 'income').fold<int>(0, (s, t) => s + t.amount).toDouble());
      expenses.add(monthTx.where((t) => t.type == 'expense').fold<int>(0, (s, t) => s + t.amount).toDouble());
    }
    final maxVal = [...incomes, ...expenses].fold<double>(0, (a, b) => math.max(a, b));
    if (maxVal == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Arus kas', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                GestureDetector(
                  onTap: () => context.push('/statistics'),
                  child: Text('Lihat semua', style: GoogleFonts.inter(fontSize: 11, color: colors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(months.length, (i) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: maxVal > 0 ? (incomes[i] / maxVal * 80) : 0,
                                    decoration: BoxDecoration(
                                      color: AppColors.teal.withValues(alpha: 0.7),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Container(
                                    height: maxVal > 0 ? (expenses[i] / maxVal * 80) : 0,
                                    decoration: BoxDecoration(
                                      color: AppColors.rose.withValues(alpha: 0.8),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(months[i], style: GoogleFonts.inter(fontSize: 9, color: colors.textSecondary), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(AppColors.teal.withValues(alpha: 0.7), 'Pemasukan'),
                const SizedBox(width: 16),
                _legendDot(AppColors.rose.withValues(alpha: 0.8), 'Pengeluaran'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, VoidCallback? onSeeAll) {
    final colors = AppColorsT.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8)),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text('Lihat semua', style: GoogleFonts.inter(fontSize: 12, color: colors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildTxTile(BuildContext context, Transaction t, NumberFormat fmt) {
    final colors = AppColorsT.of(context);
    final isIncome = t.type == 'income';
    final color = isIncome ? AppColors.teal : AppColors.rose;
    final sign = isIncome ? '+' : '-';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (t.description != null && t.description!.isNotEmpty) ? t.description! : (isIncome ? 'Pemasukan' : 'Pengeluaran'),
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary),
                ),
                Text(
                  DateFormat('HH:mm').format(t.date),
                  style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Text('$sign${fmt.format(t.amount)}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colors = AppColorsT.of(context);
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: colors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('Belum ada transaksi', style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
